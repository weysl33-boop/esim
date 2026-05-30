<?php

namespace App\EsimProviders;

use App\Lib\CurlRequest;
use App\Models\Country;
use App\Models\Region;
use Exception;

class EsimAccess {

    private $provider;
    private $baseUrl = "https://api.esimaccess.com/api/v1/open";

    public function __construct($provider) {
        $this->provider = $provider;
        $credentials = $provider->credentials;
        if (!isset($credentials->access_code) || !isset($credentials->secret_key)) {
            throw new Exception("Credentials doesn't match");
        }
    }

    public function fetchRegions() {
        try {
            $bodyArray = [
                "type" => ""
            ];

            $requestBody = json_encode($bodyArray, JSON_UNESCAPED_SLASHES);

            $response = CurlRequest::curlPostContent($this->baseUrl . '/location/list', $requestBody, $this->getHeaders());
            $response = json_decode($response, true);

            if (isset($response['success']) && $response['success']) {
                $regions = array_filter($response['obj']['locationList'], function ($obj) {
                    return $obj['type'] == 2;
                });

                $regionArray = [];
                foreach ($regions as $region) {
                    $regionArray[] = [
                        'name' => $region['name'],
                        'slug' => $region['code'],
                        'esimaccess_uid' => $region['code']
                    ];
                }

                return $regionArray;
            } else {
                throw new Exception($response['errorMsg']);
            }
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchCountries() {
        try {
            $bodyArray = [
                "type" => ""
            ];

            $requestBody = json_encode($bodyArray, JSON_UNESCAPED_SLASHES);

            $response = CurlRequest::curlPostContent($this->baseUrl . '/location/list', $requestBody, $this->getHeaders());
            $response = json_decode($response, true);

            if (isset($response['success']) && $response['success']) {
                $respCountires = array_filter($response['obj']['locationList'], function ($item) {
                    return $item['type'] == 1;
                });

                $countries = array_map(function ($item) {
                    return [
                        'esim_provider_id' => $this->provider->id,
                        'name' => $item['name'],
                        'code' => $item['code'],
                        'esimaccess_uid' => $item['code']
                    ];
                }, $respCountires);

                return $countries;
            } else {
                throw new Exception('Regions not found');
            }
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchPlans($bodyArray = null) {
        try {
            if ($bodyArray == null) {
                $bodyArray = [
                    "locationCode" => "",
                    "type" => "BASE",
                    "slug" => "",
                    "packageCode" => "",
                    "iccid" => ""
                ];
            }

            $requestBody = json_encode($bodyArray, JSON_UNESCAPED_SLASHES);
            $countries = Country::all();
            $regions   = Region::all();

            $response = CurlRequest::curlPostContent($this->baseUrl . '/package/list', $requestBody, $this->getHeaders());
            $response = json_decode($response, true);
            $planArray = [];

            if (isset($response['success']) &&  $response['success']) {
                foreach ($response['obj']['packageList'] as $item) {
                    $countryCodes = array_column($item['locationNetworkList'], 'locationCode');
                    $countryIds = $countries->whereIn('code', $countryCodes)->pluck('id')->toArray();

                    $region = null;
                    $areaCoverage = 'local';
                    if (count($countryIds) > 1) {
                        $regionSlug = explode('_', $item['slug'])[0]; //EU-42
                        $region = $regions->where('slug', $regionSlug)->first();

                        if (!$region) {
                            $regionSlug = explode('-', $regionSlug)[0];
                            $region = $regions->where('slug', 'like', "$regionSlug%%")->first();
                        }
                    }

                    if ($region) {
                        if (str()->startsWith($region->esimaccess_uid, 'GL-')) {
                            $areaCoverage = 'global';
                        } else {
                            $areaCoverage = 'continental';
                        }
                    }

                    $planArray[] = [
                        'esim_provider_id' => $this->provider->id,
                        'provider_plan_id' => $item['packageCode'],
                        'region_id' => $region ? $region->id : null,
                        'name' => $item['name'],
                        'slug' => $item['slug'],
                        'period' => daysInDay($item['duration'], $item['durationUnit']),
                        'package_type' => $item['smsStatus'] == 0 ? 'DATA' : 'SMS-DATA',
                        'data_volume' => $item['volume'],
                        'retail_price' => $item['retailPrice'] / 10000,
                        'retail_price_currency' => $item['currencyCode'],
                        'reloadable' => $item['supportTopUpType'] == 2 ? 1 : 0,
                        'refundable' => 0,
                        'phone_number' => 0,
                        'status' => 1,
                        'network_speed' => $item['speed'],
                        'area_coverage' => $areaCoverage,
                        'country_ids' => $countryIds,
                    ];
                }

                return $planArray;
            } else {
                throw new Exception($response['errorMsg']);
            }
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchSinglePlan($plan) {
        try {
            $bodyArray = [
                "locationCode" => "",
                "type" => "",
                "slug" => $plan->slug,
                "packageCode" => $plan->provider_plan_id,
                "iccid" => ""
            ];

            $requestBody = json_encode($bodyArray, JSON_UNESCAPED_SLASHES);

            $response = CurlRequest::curlPostContent($this->baseUrl . '/package/list', $requestBody, $this->getHeaders());
            $response = json_decode($response, true);

            if (isset($response['success']) && $response['success']) {
                return $response;
            } else {
                throw new Exception('Plan is not available');
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function purchasePlan($order) {
        $plan = $order->orderItem->plan;
        $data = [
            'transactionId' => $order->order_number,
            'packageInfoList' => [[
                'packageCode' => $plan->provider_plan_id,
                'count' => 1
            ]]
        ];

        $data = json_encode($data, JSON_UNESCAPED_SLASHES);

        try {
            $response = CurlRequest::curlPostContent($this->baseUrl . '/esim/order', $data, $this->getHeaders());
            $response = json_decode($response, true);

            if (isset($response['success']) && $response['success']) {
                return [
                    'esim_processed' => false,
                    'purchase_id' => $response['obj']['orderNo'],
                ];
            } else {
                throw new Exception($response['errorMsg']);
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function retriveEsimByOrderNumber($orderNumber) {
        try {
            $data = [
                'orderNo' => $orderNumber,
                'pager' => [
                    'pageNum' => 1,
                    'pageSize' => 50
                ]
            ];

            $data = json_encode($data, JSON_UNESCAPED_SLASHES);

            $response = CurlRequest::curlPostContent($this->baseUrl . '/esim/query', $data, $this->getHeaders());
            $response = json_decode($response, true);

            if (isset($response['success']) && $response['success']) {
                return $response['obj']['esimList'][0];
            } else {
                throw new Exception($response['errorMsg']);
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function getTopupPlans($esim) {
        try {
            $bodyArray = [
                "locationCode" => "",
                "type" => "TOPUP",
                "packageCode" => $esim->orderItem?->plan?->provider_plan_id ?? "",
                "iccid" => $esim->iccid
            ];

            $planArray =  $this->fetchPlans($bodyArray);
            $plans = [];
            foreach ($planArray as $plan) {
                $plans[] = [
                    'slug' => $plan['slug'],
                    'currency' => $plan['retail_price_currency'],
                    'uid' => $plan['provider_plan_id'],
                    'name' => $plan['name'],
                    'data_volume' => $plan['data_volume'],
                    'price' => $plan['retail_price'],
                    'validity' => $plan['period'],
                    'voice_quantity' => 0,
                    'sms_quantity' => 0,
                ];
            }

            return [
                'status' => 'success',
                'data' => $plans,
            ];
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function topup($topup) {
        try {
            $data = [
                'esimTranNo' => $topup->esim->info->esimTranNo ?? '',
                'iccid' => $topup->esim->iccid,
                'packageCode' => $topup->unique_id,
                'transactionId' => $topup->trx
            ];

            $data  = json_encode($data, JSON_UNESCAPED_SLASHES);
            $response = CurlRequest::curlPostContent($this->baseUrl . '/esim/topup', $data, $this->getHeaders());
            $response = json_decode($response, true);

            if (isset($response['success']) && $response['success']) {
                return [
                    'status' => 'success',
                    'message' => 'Topup completed successful',
                    'info' => [
                        'topUpEsimTranNo' => $response['obj']['topUpEsimTranNo'] ?? '',
                    ]
                ];
            } else {
                return [
                    'status' => 'error',
                    'failed_reason' => $response['errorMsg'] ?? 'API error: Unknown error',
                ];
            }
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function getRemainingCapacity($esim) {
        try {
            $data = [
                'esimTranNoList' => [$esim->info->esimTranNo]
            ];

            $response = CurlRequest::curlPostContent($this->baseUrl . '/esim/usage/query',  json_encode($data), $this->getHeaders());
            $response = json_decode($response, true);

            if (isset($response['success']) && $response['success']) {
                if (empty($response['obj']['esimUsageList'])) {
                    return [
                        'remaining_capacity' => $esim->orderItem->plan->readableDataVolume,
                        'plan_expiry' => showDateTime($esim->expiry_date),
                        'esim_expiry' => showDateTime($esim->expiry_date),
                        'voice_quantity' => 0,
                        'sms_quantity' => 0,
                    ];
                }

                $esimUsage = $response['obj']['esimUsageList'][0];
                $data = dataVolume($esimUsage['totalData'] - $esimUsage['dataUsage']);
                return [
                    'remaining_capacity' => $data['capacity'] . ' ' . $data['unit'],
                    'plan_expiry' => showDateTime($esim->expiry_date),
                    'esim_expiry' => showDateTime($esim->expiry_date),
                    'voice_quantity' => 0,
                    'sms_quantity' => 0,
                ];
            } else {
                throw new Exception($response['errorMsg']);
            }
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }
        if (isset($response['error'])) {
            throw new Exception($response['error']);
        }

        return $response;
    }

    private function getHeaders() {
        return [
            'Content-Type: application/json',
            'RT-AccessCode: ' . $this->provider->credentials->access_code
        ];
    }
}
