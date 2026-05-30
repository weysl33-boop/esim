<?php

namespace App\EsimProviders;

use App\Lib\CurlRequest;
use App\Models\Country;
use App\Models\Region;
use Exception;

class DataPlans {
    private $credentials;
    private $provider;
    private $baseUrl = 'https://app.dataplans.io/api/v1';

    public function __construct($provider) {
        $this->provider = $provider;
        $this->credentials = $provider->credentials;
        if (!isset($this->credentials->api_key)) {
            throw new Exception("Credentials doesn't match");
        }
    }

    public function fetchRegions() {
        try {
            $response = CurlRequest::curlContent($this->baseUrl . '/regions', $this->getHeader());
            $response = json_decode($response, true);
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }

        if (isset($response['error'])) {
            throw new Exception('Failed to fetch regions: ' . $response['error']);
        }

        $regions = array_map(function ($item) {
            return [
                'name' => $item['name'],
                'slug' => $item['slug'],
                'dataplansio_uid' =>  $item['slug']
            ];
        }, $response);

        return $regions;
    }

    public function fetchCountries() {
        try {
            $response = CurlRequest::curlContent($this->baseUrl . '/countries', $this->getHeader());
            $response = json_decode($response, true);
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }

        if (isset($response['error'])) {
            throw new Exception('Failed to fetch countries: ' . $response['error']);
        }


        $countryArray = array_map(function ($item) {
            return [
                'code' => $item['countryCode'],
                'name' => $item['countryName'],
                'dataplansio_uid' =>  $item['countryCode']
            ];
        }, $response);

        return $countryArray;
    }

    public function fetchPlans() {
        try {
            $response = CurlRequest::curlContent($this->baseUrl . '/plans', $this->getHeader());
            $response = json_decode($response, true);
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }

        if (isset($response['error'])) {
            throw new Exception('Failed to fetch plans: ' . $response['error']);
        }

        $countries = Country::all();
        $regions = Region::all();


        $planArray = [];
        foreach ($response as $item) {
            $region = $regions->where('dataplansio_uid', $item['region']['slug'])->first();
            $countryIds = $countries->whereIn('code', array_column($item['countries'], 'countryCode'))->pluck('id')->toArray();

            if($region){
                $areaCoverage = $region->dataplansio_uid == 'local' ? 'local' : ($region->dataplansio_uid == 'global' ? 'global' : 'continental');
            }else{
                $areaCoverage = 'local';
            }

            $planArray[] = [
                'esim_provider_id' => $this->provider->id,
                'region_id' => $region ? $region->id : null,
                'period' => daysInDay($item['period']),
                'name' => $item['name'],
                'slug' => $item['slug'],
                'package_type' => 'DATA',
                'data_volume' => dataInBytes($item['capacity'], $item['capacityUnit']),
                'retail_price' => $item['retailPrice'],
                'retail_price_currency' => $item['priceCurrency'],
                'reloadable' => $item['reloadable'],
                'phone_number' => $item['phoneNumber'],
                'operator_name' => $item['operator']['name'],
                'operator_slug' => $item['operator']['slug'],
                'area_coverage' => $areaCoverage,
                'status' => $item['active'],
                'country_ids' => $countryIds
            ];
        }

        return $planArray;
    }

    public function fetchSinglePlan($plan) {
        try {
            $url      = $this->baseUrl . "/plan/{$plan->slug}";
            $response = CurlRequest::curlContent($url, $this->getHeader());
            $response = json_decode($response, true);

            if (!$response['active']) {
                throw new Exception('Plan is currently inactive');
            }
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }

        if (isset($response['error'])) {
            throw new Exception($response['error']);
        }

        return $response;
    }

    public function purchasePlan($order) {
        $plan = $order->orderItem->plan;
        try {
            $response = CurlRequest::curlPostContent($this->baseUrl . '/purchases', ['slug' => $plan->slug], $this->getHeader());
            $response = json_decode($response, true);

            if (isset($response['error'])) {
                throw new Exception($response['error']);
            }

            if (empty($response['purchase']) || empty($response['purchase']['esim'])) {
                throw new Exception('The plan is currently unavailable');
            }

            $response = [
                'esim_processed' => true,
                'paid_amount'    => $response['purchase']['paid'],
                'purchase_id'    => $response['purchase']['purchaseId'],
                'serial_number'  => $response['purchase']['esim']['serial'],
                'phone_number'   => $response['purchase']['esim']['phone'] == 'empty' ? null : $response['purchase']['esim']['phone'],
                'qr_code'        => $response['purchase']['esim']['qrCodeString'],
                'expiry_date'    => $response['purchase']['esim']['expiryDate'],

            ];

            return $response;
        } catch (Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    public function getRemainingCapacity($esim) {
        $operatorSlug = $esim->orderItem->plan->operator_slug;
        $phoneNumber  = $esim->phone_number;

        try {
            $url      = $this->baseUrl . "/status/{$operatorSlug}/{$phoneNumber}";
            $response = CurlRequest::curlContent($url, $this->getHeader());
            $response = json_decode($response, true);

            $plan = $response['plans'][0];

            if (!$plan) {
                return [
                    'error' => 'No plan data found in response.'
                ];
            }

            $response = [
                'remaining_capacity' => $plan['remainingCapacity'] . ' ' . $plan['capacityUnit'],
                'plan_expiry' => showDateTime($plan['expiryDate'], 'd M Y, h:i A'),
                'esim_expiry' => showDateTime($response['esim']['expiryDate'], 'd M Y, h:i A')
            ];
        } catch (\Exception $e) {
            throw new Exception($e->getMessage());
        }
        if (isset($response['error'])) {
            throw new Exception($response['error']);
        }

        return $response;
    }

    private function getHeader() {

        return [
            "Authorization: " . $this->credentials->api_key,
            'Accept: application/json',
        ];
    }
}
