<?php

namespace App\EsimProviders;

use App\Lib\CurlRequest;
use App\Models\Country;
use App\Models\Region;
use Carbon\Carbon;
use Exception;

class EsimCard {
    private $provider;
    private $baseUrl = "https://portal.esimcard.com/api/developer/reseller";
    private $credentials;
    private $packageTypes = ['DATA-ONLY', 'DATA-VOICE-SMS'];

    public function __construct($provider) {
        $this->provider = $provider;
        $credentials = $provider->credentials;
        if (!isset($credentials->email) || !isset($credentials->password)) {
            throw new Exception("Credentials doesn't match");
        }

        $this->credentials = $this->getCredentails();
    }

    public function fetchRegions() {
        try {
            $response = CurlRequest::curlContent($this->baseUrl . '/packages/continent', $this->getHeaders());
            $response = json_decode($response, true);

            if (isset($response['status']) && $response['status']) {
                $regionArray = array_map(function ($item) {
                    return [
                        'name' => $item['name'],
                        'slug' => $item['code'],
                        'esimcard_uid' => $item['id']
                    ];
                }, $response['data']);

                return $regionArray;
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchCountries() {
        try {
            $response = CurlRequest::curlContent($this->baseUrl . '/packages/country', $this->getHeaders());
            $response = json_decode($response, true);

            if (isset($response['status']) && $response['status']) {
                $countries = array_map(function ($item) {
                    return [
                        'name' => $item['name'],
                        'code' => $item['code'],
                        'esimcard_uid' => $item['id']
                    ];
                }, $response['data']);

                return $countries;
            } else {
                throw new Exception(@$response['message']);
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchPlans() {
        try {

            $planArray = [];
            $globalPackages = $this->fetchGlobalPlans();

            if (count($globalPackages)) {
                $planArray = array_merge($planArray, $globalPackages);
            }

            $continentalPackages = $this->fetchContinentalPlans();

            if (count($continentalPackages)) {
                $planArray = array_merge($planArray, $continentalPackages);
            }

            $countryPackages = $this->fetchCountryPlans();

            if (count($countryPackages)) {
                $planArray = array_merge($planArray, $countryPackages);
            }

            return $planArray;
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchCountryPlans() {
        $countries = Country::whereNotNull('esimcard_uid')->get();
        $planArray = [];

        try {
            foreach ($countries as $country) {
                $countryPlans = $this->fetchCountryPlansById($country);
                if (!empty($countryPlans)) {
                    $planArray = array_merge($planArray, $countryPlans);
                }
            }

            return $planArray;
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchCountryPlansById($country) {
        $planArray = [];

        try {
            foreach ($this->packageTypes as $packageType) {
                $page = 1;
                $lastPage = 1;

                do {
                    $url = $this->baseUrl . '/packages/country/' . $country->esimcard_uid . '/' . $packageType . '?per_page=50&page=' . $page;
                    $response = CurlRequest::curlContent($url, $this->getHeaders());
                    $response = json_decode($response, true);

                    if (isset($response['status']) && $response['status']) {
                        foreach ($response['data'] as $item) {
                            $planArray[] = [
                                'esim_provider_id'      => $this->provider->id,
                                'provider_plan_id'      => $item['id'],
                                'name'                  => $item['name'],
                                'slug'                  => str()->slug($item['name']),
                                'period'                => daysInDay($item['package_validity'], $item['package_validity_unit']),
                                'package_type'          => $item['package_type'] == 'DATA-ONLY' ? 'DATA' : $item['package_type'],
                                'data_volume'           => dataInBytes($item['data_quantity'], $item['data_unit']),
                                'voice_quantity'        => voiceInMinutes($item['voice_quantity'], $item['voice_unit']),
                                'sms_quantity'          => $item['sms_quantity'],
                                'retail_price'          => $item['price'] + gs('additional_price'),
                                'retail_price_currency' => $this->provider->currency,
                                'reloadable'            => 0,
                                'refundable'            => 0,
                                'phone_number'          => 0,
                                'network_speed'         => $item['connectivity'],
                                'area_coverage'         => 'local',
                                'status'                => 1,
                                'country_ids'           => [$country->id]
                            ];
                        }

                        $lastPage = $response['meta']['lastPage'] ?? $page;
                    } else {
                        break;
                    }

                    $page++;
                } while ($page <= $lastPage);
            }

            return $planArray;
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }


    public function fetchContinentalPlans() {
        $regions = Region::whereNotNull('esimcard_uid')->get();
        $planArray = [];

        try {
            foreach ($regions as $region) {
                $regionPlans = $this->fetchContinentalPlansById($region);
                if (!empty($regionPlans)) {
                    $planArray = array_merge($planArray, $regionPlans);
                }
            }
            return $planArray;
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchContinentalPlansById($region) {
        $planArray = [];
        $countries = Country::whereNotNull('esimcard_uid')->get();

        try {
            foreach ($this->packageTypes as $packageType) {
                $page = 1;
                $lastPage = 1;

                do {
                    $url = $this->baseUrl . '/packages/continent/' . $region->esimcard_uid . '/' . $packageType . '?per_page=50&page=' . $page;
                    $response = CurlRequest::curlContent($url, $this->getHeaders());
                    $response = json_decode($response, true);

                    if (isset($response['status']) && $response['status']) {
                        foreach ($response['data'] as $item) {
                            $countryIds = $countries->whereIn('esimcard_uid', array_column($item['countries'], 'id'))->pluck('id')->toArray();

                            $planArray[] = [
                                'esim_provider_id'      => $this->provider->id,
                                'provider_plan_id'      => $item['id'],
                                'region_id'             => $region->id,
                                'name'                  => $item['name'],
                                'slug'                  => str()->slug($item['name']),
                                'period'                => daysInDay($item['package_validity'], $item['package_validity_unit']),
                                'package_type'          => $item['package_type'] == 'DATA-ONLY' ? 'DATA' : $item['package_type'],
                                'data_volume'           => dataInBytes($item['data_quantity'], $item['data_unit']),
                                'voice_quantity'        => voiceInMinutes($item['voice_quantity'], $item['voice_unit']),
                                'sms_quantity'          => $item['sms_quantity'],
                                'retail_price'          => $item['price'] + gs('additional_price'),
                                'retail_price_currency' => $this->provider->currency,
                                'reloadable'            => 0,
                                'refundable'            => 0,
                                'phone_number'          => 0,
                                'network_speed'         => $item['connectivity'],
                                'area_coverage'         => 'continental',
                                'status'                => 1,
                                'country_ids'           => $countryIds
                            ];
                        }

                        $lastPage = $response['meta']['lastPage'] ?? $page;
                    } else {
                        break;
                    }

                    $page++;
                } while ($page <= $lastPage);
            }
            return $planArray;
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchGlobalPlans() {
        try {
            $planArray = [];
            $countries = Country::all();

            foreach ($this->packageTypes as $packageType) {
                $page = 1;
                $lastPage = 1;

                do {
                    $url = $this->baseUrl . '/packages/global/' . $packageType . '?per_page=50&page=' . $page;
                    $response = CurlRequest::curlContent($url, $this->getHeaders());
                    $response = json_decode($response, true);

                    if (isset($response['status']) && $response['status']) {
                        foreach ($response['data'] as $item) {
                            $countryIds = $countries->whereIn('esimcard_uid', array_column($item['countries'], 'id'))->pluck('id')->toArray();

                            $planArray[] = [
                                'esim_provider_id'      => $this->provider->id,
                                'provider_plan_id'      => $item['id'],
                                'name'                  => $item['name'],
                                'slug'                  => str()->slug($item['name']),
                                'period'                => daysInDay($item['package_validity'], $item['package_validity_unit']),
                                'package_type'          => $item['package_type'] == 'DATA-ONLY' ? 'DATA' : $item['package_type'],
                                'data_volume'           => dataInBytes($item['data_quantity'], $item['data_unit']),
                                'voice_quantity'        => voiceInMinutes($item['voice_quantity'], $item['voice_unit']),
                                'sms_quantity'          => $item['sms_quantity'],
                                'retail_price'          => $item['price'] + gs('additional_price'),
                                'retail_price_currency' => $this->provider->currency,
                                'reloadable'            => 0,
                                'refundable'            => 0,
                                'phone_number'          => 0,
                                'network_speed'         => $item['connectivity'],
                                'area_coverage'         => 'global',
                                'status'                => 1,
                                'country_ids'           => $countryIds
                            ];
                        }

                        $lastPage = $response['meta']['lastPage'] ?? $page;
                    } else {
                        break;
                    }

                    $page++;
                } while ($page <= $lastPage);
            }

            return $planArray;
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function purchasePlan($order) {
        $plan = $order->orderItem->plan;

        try {
            $body = [
                'package_type_id' => $plan->provider_plan_id
            ];

            $url = $this->baseUrl .  ($plan->package_type == 'DATA' ? '/package/purchase' : '/package/date_voice_sms/purchase');
            $response = CurlRequest::curlPostContent($url, json_encode($body), $this->getHeaders());
            $response = json_decode($response, true);

            if (isset($response['status']) && $response['status']) {
                $data = $response['data'];
                $response = [
                    'esim_processed' => true,
                    'iccid' => $data['sim']['iccid'],
                    'qr_code' => $data['sim']['qr_code_text'],
                    'phone_number' => $data['sim']['number'],
                    'expiry_date' => Carbon::parse($data['package']['date_expiry'])->format('Y-m-d'),
                    'info' => [
                        'id' => $data['sim']['id'],
                        'smdp_address' => $data['sim']['smdp_address'],
                        'matching_id' => $data['sim']['matching_id'],
                        'apn' => $data['sim']['apn'],
                        'puk_code' => $data['sim']['puk_code'],
                    ]
                ];

                return $response;
            } else {
                throw new Exception(isset($response['message']) ? $response['message'] : 'Can\'t purchase this package.');
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function fetchSinglePlan($plan) {
        try {
            $response = CurlRequest::curlContent($this->baseUrl . '/package/detail/' . $plan->provider_plan_id, $this->getHeaders());
            $response = json_decode($response, true);
            if (isset($response['status']) && $response['status']) {
                return $response;
            } else {
                throw new Exception('Plan is not available');
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function getRemainingCapacity($esim) {
        try {
            $response = CurlRequest::curlContent($this->baseUrl . '/my-sim' . '/' . $esim->iccid . '/usage', $this->getHeaders());
            $response = json_decode($response, true);
            if (isset($response['status']) && $response['status']) {
                return [
                    'remaining_capacity' => $response['data']['rem_data_quantity'] . ' ' . $response['data']['rem_data_unit'],
                    'plan_expiry' => showDateTime($esim->expiry_date),
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
        return  [
            'status' => 'error',
            'message' => 'Top-up plans are not available for this provider'
        ];
    }

    private function getCredentails() {
        try {
            $data = [
                'email' => $this->provider->credentials->email,
                'password' => $this->provider->credentials->password,
            ];

            $response = CurlRequest::curlPostContent($this->baseUrl . '/login', $data);
            $response = json_decode($response, true);

            if (isset($response['status']) && $response['status']) {
                return [
                    'access_token' => $response['access_token'],
                    'token_type'   => $response['token_type'],
                ];
            } else {
                throw new Exception('Invalid login details');
            }
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    private function getHeaders() {
        return [
            'Content-Type: application/json',
            'Authorization: ' . $this->credentials['token_type'] . ' ' . $this->credentials['access_token']
        ];
    }
}
