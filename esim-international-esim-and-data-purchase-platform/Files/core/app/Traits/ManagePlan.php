<?php

namespace App\Traits;

use App\Lib\CurrencyLayer;
use App\Models\Currency;
use App\Models\Plan;

trait ManagePlan
{
    public function addOrUpdatePlans($plans){
        $newCurrencyArray = [];
        foreach ($plans as $item) {
            $plan = Plan::where('slug', $item['slug'])->first();
            $isUpdate = true;

            if (!$plan) {
                $plan = new Plan();
                $plan->slug = $item['slug'];
                $isUpdate = false;
            }

            $currencyCode = strtoupper($item['retail_price_currency']);
            if ($currencyCode != gs('cur_text')) {
                $currency = Currency::where('api_currency', $currencyCode)->first();
                if (!$currency) {
                    $currency                  = new Currency();
                    $currency->api_currency    = $currencyCode;
                    $currency->conversion_rate = null;
                    $currency->save();

                    $newCurrencyArray[] = $currencyCode;
                }

                $plan->currency_id = $currency->id;
            } else {
                $plan->currency_id = null;
            }

            $plan->esim_provider_id = $item['esim_provider_id'];
            $plan->provider_plan_id = $item['provider_plan_id'] ?? null;
            $plan->region_id        = $item['region_id'] ?? null;
            $plan->name             = $item['name'];
            $plan->period           = $item['period'];
            $plan->package_type     = $item['package_type'];
            $plan->data_volume      = $item['data_volume'];
            $plan->voice_quantity   = $item['voice_quantity'] ?? 0;
            $plan->sms_quantity     = $item['sms_quantity'] ?? 0;
            $plan->retail_price     = $item['retail_price'];
            $plan->reloadable       = $item['reloadable'];
            $plan->refundable       = $item['refundable'];
            $plan->phone_number     = $item['phone_number'] ?? 0;
            $plan->operator_name    = $item['operator_name'] ?? null;
            $plan->operator_slug    = $item['operator_slug'] ?? null;
            $plan->network_speed    = $item['network_speed'] ?? null;
            $plan->area_coverage    = $item['area_coverage'];
            $plan->status           = $isUpdate ? $plan->status : $item['status'];
            $plan->save();

            $plan->countries()->sync($item['country_ids']);
        }

        $currencyLayer = new CurrencyLayer();
        $currencyLayer->updateRates($newCurrencyArray);
    }
}
