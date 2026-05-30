<?php

namespace App\EsimProviders;

use App\Lib\CurlRequest;
use App\Models\Country;
use App\Models\Region;
use Carbon\Carbon;
use Exception;
use SendGrid\Mail\To;

class EsimSM {
    private $provider;
    private $baseUrl = "https://esim.sm/api/reseller/v1";

    public function __construct($provider) {
        $this->provider = $provider;
        $credentials = $provider->credentials;

        if (!isset($credentials->api_key)) {
            throw new Exception("Credentials doesn't match");
        }
    }

    public function fetchRegions() {
        try {
            $response = CurlRequest::curlContent($this->baseUrl . '/country?hl=en&currency=' . $this->provider->currency, $this->getHeaders());
            $response = json_decode($response, true);

            if (isset($response['success']) && $response['success']) {
                $regions = array_unique(array_column($response['data'], 'region'));

                $regionArray = [];
                foreach ($regions as $region) {
                    $regionArray[] = [
                        'name' => ucWords($region),
                        'slug' => $region,
                        'esimsm_uid' => $region
                    ];
                }

                return $regionArray;
            } else {
                throw new Exception('Regions not found');
            }
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchCountries() {
        try {
            $response = CurlRequest::curlContent($this->baseUrl . '/country?hl=en&currency=' . $this->provider->currency, $this->getHeaders());
            $response = json_decode($response, true);

            if (isset($response['success']) && $response['success']) {
                $countryArray = [];

                $countries = array_filter($response['data'], function ($item) {
                    return $item['isRegion'] == false;
                });

                $countryArray = array_map(function ($item) {
                    return [
                        'code' => $item['id'],
                        'name' => $item['name'],
                        'esimsm_uid' => $item['id'],
                    ];
                }, $countries);

                return $countryArray;
            } else {
                throw new Exception('Regions not found');
            }
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchPlans() {
        try {
            $regions = Region::all();
            $countries = Country::all();
            $planArray = [];

            foreach ($countries as $country) {
                $response = CurlRequest::curlContent($this->baseUrl . '/country?id=' . $country->code . '&currency=' . $this->provider->currency, $this->getHeaders());
                $response = json_decode($response, true);
                if (isset($response['success']) && $response['success']) {
                    foreach ($response['data']['plans'] as $item) {
                        $region = null;
                        $countryIds = $countries->whereIn('code', $item['countries'])->pluck('id')->toArray();
                        if ($item['regionId']) $region = $regions->where('slug', $item['regionId'])->first();

                        $planArray[] = [
                            'esim_provider_id'      => $this->provider->id,
                            'provider_plan_id'      => $item['id'],
                            'region_id'             => $region ? $region->id : null,
                            'name'                  => $item['name'],
                            'slug'                  => 'e-sm-' . str()->slug($item['name']),
                            'package_type'          => 'DATA',
                            'period'                => daysInDay($item['days']),
                            'data_volume'           => dataInBytes($item['mb'], 'MB'),
                            'retail_price'          => $item['price'] + gs('additional_price'),
                            'retail_price_currency' => $item['currency'],
                            'reloadable'            => $item['hasTopUps'] ? 1 : 0,
                            'refundable'            => $item['isRefundable'] ? 1 : 0,
                            'phone_number'          => $item['hasPhoneNumber'],
                            'network_speed'         => $item['networkSpeed'],
                            'area_coverage'         => $region ? 'continental' : 'local',
                            'status'                => $item['isActive'],
                            'country_ids'           => $countryIds
                        ];
                    }
                }
            }
            return $planArray;
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchSinglePlan($plan) {
        try {
            $response = CurlRequest::curlContent($this->baseUrl . '/plan?id=' . $plan->provider_plan_id . '&currency=' . $this->provider->currency, $this->getHeaders());
            $response = json_decode($response, true);
            if (!isset($response['plan'])) {
                throw new Exception('Plan is not available');
            }

            if (!$response['plan']['isActive']) {
                throw new Exception('Plan is currently inactive');
            }

            return $response;
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function purchasePlan($order) {
        $plan = $order->orderItem->plan;
        $data = [
            'plan_id' => $plan->provider_plan_id,
            'quantity' => 1
        ];

        try {
            $response = CurlRequest::curlPostContent($this->baseUrl . '/esim/purchase', $data, $this->getHeaders());
            $response = json_decode($response, true);
            if (isset($response['success'])  && $response['success']) {
                $esim = $response['data']['esim'][0];
                $response = [
                    'esim_processed' => true,
                    'paid_amount' => $esim['customerPaidUsd'],
                    'purchase_id' => $esim['id'],
                    'iccid' => $esim['iccid'],
                    'qr_code_image' => $esim['qrCode'],
                    'expiry_date' => Carbon::parse($esim['expirationTimestamp'])->format('Y-m-d'),
                ];

                return $response;
            } else {
                throw new Exception('Faild to purchase the plan');
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function getRemainingCapacity($esim) {
        try {
            $response = CurlRequest::curlContent($this->baseUrl . '/esim?iccid=' . $esim->iccid, $this->getheaders());
            $response = json_decode($response, true);
            if (isset($response['success']) && $response['success']) {
                $response = $response['data'];
                $remainingCapacity = ($response['mbTotal'] - $response['mbUsed']) / 1024;
                $response = [
                    'remaining_capacity' => $remainingCapacity . ' GB',
                    'plan_expiry' => showDateTime($response['expirationTimestamp'], 'd M, Y h:i A'),
                ];

                return $response;
            } else {
                throw new Exception('Can\'t find any eSIM');
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function cancelEsim($esim) {
        try {
            $data = [
                'iccid' => $esim->iccid,
            ];
            $response = CurlRequest::curlPostContent($this->baseUrl . '/esim/refund', $data, $this->getHeaders());
            $response = json_decode($response, true);
            if (isset($response['success']) && $response['success']) {
                return [
                    'status' => 'success',
                    'message' => 'eSIM canceled successfully'
                ];
            } else {
                throw new Exception($response['error'] ?? 'Failed to cancel the eSIM');
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function getTopupPlans($esim) {
        try {
            $response = CurlRequest::curlContent($this->baseUrl . '/plan?id=' . $esim->orderItem->plan_id, $this->getHeaders());
            $response = json_decode($response, true);
            if (isset($response['plan'])) {
                $plan = $response['plan'];
                if (isset($plan['refillOptions'])) {
                    $plans = [];
                    foreach ($plan['refillOptions'] as $key => $topupPlan) {
                        if ($topupPlan['isActive'] == false) {
                            continue;
                        }

                        $plans[$key]['uid'] = $topupPlan['id'];
                        $plans[$key]['price'] = $topupPlan['price'];
                        $plans[$key]['data_volume'] = dataInBytes($topupPlan['mb'], 'MB');
                        $plans[$key]['voice_quantity'] = null;
                        $plans[$key]['sms_quantity'] = null;
                        $plans[$key]['validity'] = $topupPlan['days'];
                        $plans[$key]['currency'] = $plan['currency'];
                        $plans[$key]['name'] = $topupPlan['label'];
                    }

                    return [
                        'status' => 'success',
                        'data' => $plans
                    ];
                } else {
                    throw new Exception('No topup plans found');
                }
            } else {
                throw new Exception('No topup plans found');
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function topup($topup) {
        $esim = $topup->esim;
        $data = [
            'iccid' => $esim->iccid,
            'refill' => $topup->unique_id
        ];

        try {
            $response = CurlRequest::curlPostContent($this->baseUrl . '/esim/top-up', $data, $this->getHeaders());
            $response = json_decode($response, true);
            if (isset($response['success']) && $response['success']) {
                return [
                    'status' => 'success',
                    'message' => 'Topup completed successful'
                ];
            } else {
                throw new Exception($response['error'] ?? 'Failed to topup the eSIM');
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    private function getHeaders() {
        $credentials = $this->provider->credentials;

        return [
            "Authorization: Bearer " . $credentials->api_key,
            "Accept: application/json",
        ];
    }
}
