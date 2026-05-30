<?php

namespace App\EsimProviders;

use App\Constants\Status;
use App\Lib\CurlRequest;
use App\Models\Country;
use App\Models\Region;
use Carbon\Carbon;
use Exception;
use Illuminate\Support\Facades\Cache;
use Illuminate\Validation\ValidationException;

class AirAlo {
    private $credentials;
    private $provider;
    private $baseUrl = 'https://partners-api.airalo.com';
    private $token;

    public function __construct($provider) {
        $this->provider = $provider;
        $this->credentials = $provider->credentials;

        if (!isset($this->credentials->clent_id) &&  !isset($this->credentials->client_secret)) {
            throw ValidationException::withMessages(['error' => "Credentials doesn't match"]);
        }

        $this->token = Cache::get('airalo-token');
        if (!$this->token) {
            $response = $this->getAccessToken();
            if (!$response['status']) {
                throw ValidationException::withMessages(['error' => $response['message']]);
            }
        }
    }

    public function fetchRegions() {
        try {
            $response = $this->fetchAllPages($this->baseUrl . '/v2/packages?filter[type]=global');
            if ($response['status']) {
                $data = $response['data'];
                $data = array_filter($data, fn($item) => $item->slug != 'world');
                $regions = array_map(function ($item) {
                    if ($item->slug != 'world') {
                        return [
                            'name' => $item->title,
                            'slug' => $item->slug,
                            'airalo_uid' => $item->slug
                        ];
                    }
                }, $data);

                return $regions;
            } else {
                throw new Exception($response['message']);
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchCountries() {
        try {
            $response = $this->fetchAllPages($this->baseUrl . '/v2/packages?filter[type]=local');
            if ($response['status']) {
                $data = $response['data'];
                $countries = [];
                foreach ($data as $item) {
                    $code = $item->country_code;
                    $countries[$code] = [
                        'name'       => $item->title,
                        'code'       => $code,
                        'airalo_uid' => $code,
                    ];
                }

                $countries = array_values($countries);
                return $countries;
            } else {
                throw new Exception($response['message']);
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchPlans() {
        $planArray = [];
        $countries = Country::all();
        $regions = Region::all();

        try {
            $response = $this->fetchAllPages($this->baseUrl . '/v2/packages');
            if ($response['status']) {
                $data = $response['data'];

                $regionId = null;
                foreach ($data as $item) {
                    $region  = $regions->where('airalo_uid', $item->slug)->first();
                    if ($item->slug == 'world') {
                        $coverageArea = 'global';
                    } elseif ($region) {
                        $regionId = $region->id;
                        $coverageArea = 'continental';
                    } else {
                        $coverageArea = 'local';
                    }

                    foreach ($item->operators as $operator) {
                        $countryCodes = array_map(fn($c) => $c->country_code, $operator->countries);
                        $countryIds = $countries->whereIn('airalo_uid', $countryCodes)->pluck('id')->toArray();

                        foreach ($operator->packages as $package) {
                            if ($package->data && $package->voice && $package->text) {
                                $packageType = 'DATA-VOICE-SMS';
                            } elseif ($package->data && $package->voice) {
                                $packageType = 'DATA-VOICE';
                            } elseif ($package->data && $package->text) {
                                $packageType = 'DATA-SMS';
                            } elseif ($package->voice && $package->text) {
                                $packageType = 'VOICE-SMS';
                            } elseif ($package->voice) {
                                $packageType = 'VOICE';
                            } elseif ($package->text) {
                                $packageType = 'SMS';
                            } else {
                                $packageType = 'DATA';
                            }

                            $prices = (array) $package->prices->recommended_retail_price;
                            if (isset($prices[gs('cur_text')])) {
                                $retailPrice = $prices[gs('cur_text')];
                                $retailPriceCurrency = gs('cur_text');
                            } else {
                                $retailPrice = reset($prices);
                                $retailPriceCurrency = key($prices);
                            }

                            $planArray[] = [
                                'esim_provider_id'      => $this->provider->id,
                                'provider_plan_id'      => $package->id,
                                'name'                  => $package->title,
                                'slug'                  => $package->id,
                                'period'                => $package->day,
                                'package_type'          => $packageType,
                                'data_volume'           => $package->is_unlimited ? -1 : dataInBytes($package->amount, 'MB'),
                                'voice_quantity'        => $package->voice,
                                'sms_quantity'          => $package->text,
                                'retail_price'          => $retailPrice,
                                'retail_price_currency' => $retailPriceCurrency,
                                'reloadable'            => $operator->rechargeability ? Status::YES : Status::NO,
                                'refundable'            => Status::NO,
                                'area_coverage'         => $coverageArea,
                                'status'                => Status::ESIM_ACTIVE,
                                'country_ids'           => $countryIds,
                                'region_id'             => $regionId,
                            ];
                        }
                    }
                }

                return $planArray;
            } else {
                throw new Exception($response['message']);
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchSinglePlan($plan) {
        return $plan;
    }

    public function purchasePlan($order) {
        $plan = $order->orderItem->plan;
        $data = [
            'package_id' => $plan->provider_plan_id,
            'quantity' => 1,
            'to_email' => $order->user->email,
            'sharing_option[]' => 'link'
        ];

        try {
            $response = CurlRequest::curlPostContent($this->baseUrl . '/v2/orders', $data, $this->getHeaders());
            $response = json_decode($response);
            if (isset($response->meta->message) && $response->meta->message == 'success') {
                if (isset($response->data->sims[0])) {
                    $sim = $response->data->sims[0];
                    $response = [
                        'esim_processed' => true,
                        'iccid' => $sim->iccid,
                        'qr_code' => $sim->qrcode,
                        'expiry_date' => Carbon::parse($response->data->created_at)->addDays($response->data->validity),
                        'info' => [
                            'id'          => $sim->id,
                            'is_roaming'  => $sim->is_roaming,
                            'lpa'         => $sim->lpa,
                            'apn_type'    => $sim->apn_type,
                            'apn_value'   => $sim->apn_value,
                            'apn'         => $sim->apn,
                            'matching_id' => $sim->matching_id,
                            'msisdn'      => $sim->msisdn,
                            'sharing'     => $sim->sharing,
                            'created_at'  => $sim->created_at,
                        ]
                    ];

                    return $response;
                } else {
                    throw new Exception('Airalo API error');
                }
            } else {
                $message = $response?->meta?->message ?? ($response?->reason ?? null);
                throw new Exception($message ?? 'Airalo API error');
            }
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function getRemainingCapacity($esim) {
        try {
            $response = CurlRequest::curlContent($this->baseUrl . '/v2/sims/' . $esim->iccid . '/usage', $this->getHeaders());
            $response = json_decode($response);
            if (isset($response->meta->message) && $response->meta->message == 'success') {
                $dataVolume  = null;
                if (!$response->data->is_unlimited) {
                    $dataVolume  = dataVolume(dataInBytes($response->data->remaining, 'MB'));
                }

                return [
                    'remaining_capacity' =>  $response->data->is_unlimited ? __('Unlimited') : ($dataVolume['capacity'] . ' ' . $dataVolume['unit']),
                    'remaining_voice' => $response->data->remaining_voice,
                    'remaining_sms' => $response->data->remaining_text,
                    'plan_expiry' => showDateTime($response->data->expired_at),
                    'esim_expiry' => showDateTime($esim->expiry_date)
                ];
            } else {
                throw new Exception('Something went wrong');
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function getTopupPlans($esim) {
        try {
            $response = CurlRequest::curlContent($this->baseUrl . '/v2/sims/' . $esim->iccid . '/topups', $this->getHeaders());
            $response = json_decode($response);
            if (isset($response->data) && count($response->data) > 0) {
                $planArray = [];
                foreach ($response->data as $item) {
                    $planArray[] = [
                        'uid'                   => $item->id,
                        'price'                  => $item->price,
                        'data_volume'           => dataInBytes($item->amount, 'MB'),
                        'voice_quantity'        => $item->voice,
                        'sms_quantity'          => $item->text,
                        'currency'              => $esim->orderItem?->plan?->esimProvider?->currency ?? gs('cur_text'),
                        'validity'              => $item->day,
                        'name'                  => $item->title,
                    ];
                }

                return [
                    'status' => 'success',
                    'data' => $planArray
                ];
            } else {
                throw new Exception('No topup plans found');
            }
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function topup($topup) {
        try {
            $body = [
                'package_id' => $topup->unique_id,
                'iccid' => $topup->esim->iccid,
                'description' => 'topup_id-' . $topup->id,
            ];

            $response = CurlRequest::curlPostContent($this->baseUrl . '/v2/orders/topups', $body, $this->getHeaders());
            $response = json_decode($response);

            if (isset($response->meta->message) && $response->meta->message == 'success') {
                return [
                    'status' => 'success',
                    'message' => 'Topup successful',
                    'info' => [
                        'code' => $response->data->code,
                        'package_id' => $response->data->package_id
                    ],
                ];
            } else {
                throw new Exception($response?->meta->message ?? 'Failed to topup the eSIM');
            }
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    protected function fetchAllPages($url) {
        $allData = [];
        $currentUrl = $url;

        do {
            $response = CurlRequest::curlContent($currentUrl, $this->getHeaders());
            $response = json_decode($response);
            if (isset($response->data)) {
                $allData = array_merge($allData, $response->data);
                $currentUrl = $response?->links?->next ?? null;
            } else {
                return [
                    'status' => false,
                    'message' => $response?->meta?->message ?? 'Data not found'
                ];
            }
        } while ($currentUrl);

        return [
            'status' => true,
            'data'   => $allData
        ];
    }

    private function getAccessToken() {
        $data = [
            'client_id' => $this->credentials->client_id,
            'client_secret' => $this->credentials->client_secret,
            'grant_type' => 'client_credentials'
        ];

        try {
            $response = CurlRequest::curlPostContent($this->baseUrl . '/v2/token', $data);
            $response = json_decode($response);

            if (isset($response->meta->message) && $response->meta->message == 'success') {
                $this->token = $response->data->access_token;
                $expiredAt = now()->addSeconds($response->data->expires_in);
                Cache::put('airalo-token', $this->token, $expiredAt);

                return [
                    'status' => true,
                    'message' => 'Token created sucessfully'
                ];
            } else {
                return [
                    'status' => false,
                    'message' => $response->meta->message
                ];
            }
        } catch (\Exception $e) {
            return [
                'status' => false,
                'message' => $e->getMessage()
            ];
        }
    }

    private function getHeaders() {
        return [
            "Authorization: Bearer " . $this->token,
            'Accept: application/json',
        ];
    }
}
