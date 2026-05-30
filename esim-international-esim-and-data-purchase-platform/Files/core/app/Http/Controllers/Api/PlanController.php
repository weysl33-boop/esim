<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Campaign;
use App\Models\Country;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Plan;
use App\Models\Region;
use Illuminate\Http\Request;

class PlanController extends Controller {
    public function campaignPlans($id) {
        $campaign = Campaign::active()->find($id);
        if (!$campaign) {
            $notify[] = 'Campaign not found';
            return responseError('campaign_not_found', $notify);
        }

        $campaign->banner_path = getImage(getFilePath('campaign') . '/' . $campaign->banner, getFileSize('campaign'));

        $plans = Plan::active()
            ->where('campaign_id', $id)
            ->whereHas('esimProvider', fn($provider) => $provider->active())
            ->with('esimProvider');

        $plans = $this->getPlans($plans);
        $notify[] = 'Campaign plans';

        return responseSuccess('campaign_plans', $notify, [
            'campaign' => $campaign,
            'plans' => $plans,
        ]);
    }

    public function countryPlans($id) {
        $country = Country::active()->whereHas('plans', function ($query) {
            $query->active()->whereHas('esimProvider', fn($provider) => $provider->active());
        })->select('id', 'name', 'slug', 'image', 'banner')->find($id);

        if (!$country) {
            $notify[] = 'Country not found';
            return responseError('country_not_found', $notify);
        }

        $country->image_path = $country->image_src;
        $country->banner_path = $country->banner_src;

        $plans = Plan::whereHas('countries', function ($query) use ($country) {
            $query->where('country_id', $country->id);
        })
            ->whereHas('esimProvider', fn($provider) => $provider->active())
            ->active();

        $plans = $this->getPlans($plans);
        $notify[] = 'Country plans';

        return responseSuccess('country_plans', $notify, [
            'country' => $country,
            'plans' => $plans
        ]);
    }

    public function continentalPlans($id) {
        $region = Region::active()->select('id', 'name', 'slug', 'region_image', 'banner')->find($id);

        if (!$region) {
            $notify[] = 'Region not found';
            return responseError('region_not_found', $notify);
        }

        $region->image_path = $region->image_src;
        $region->banner_path = $region->banner_src;

        $plans = Plan::where('region_id', $region->id)
            ->whereHas('esimProvider', fn($provider) => $provider->active())
            ->active();

        $plans = $this->getPlans($plans);
        $notify[] = 'Continental plans';

        return responseSuccess('continental_plans', $notify, [
            'region' => $region,
            'plans' => $plans,
        ]);
    }

    public function globalPlans() {
        $plans = Plan::global()
            ->whereHas('esimProvider', fn($provider) => $provider->active())
            ->active();

        $plans = $this->getPlans($plans);
        $notify[] = 'Global plans';

        return responseSuccess('global_plans', $notify, [
            'plans' => $plans,
        ]);
    }

    private function getPlans($plans) {
        $plans = $plans->with('campaign')->apiQuery();
        $plans->through(function ($item) {
            return [
                'id'             => $item->id,
                'name'           => $item->name,
                'campaign_id'    => $item->campaign_id,
                'slug'           => $item->slug,
                'package_type'   => $item->package_type,
                'data_volume'    => $item->data_volume,
                'data_unit'      => 'byte',
                'voice_quantity' => $item->voice_quantity,
                'voice_unit'     => 'minute',
                'sms_quantity'   => $item->sms_quantity,
                'period'         => $item->period,
                'period_unit'    => 'day',
                'price'          => round($item->converted_price, 2),
                'currency'       => gs('cur_text'),
                'reloadable'     => $item->reloadable,
                'refundable'     => $item->refundable,
                'phone_number'   => $item->phone_number,
                'operator_name'  => $item->operator_name,
                'network_speed'  => $item->network_speed,
                'area_coverage'  => $item->area_coverage,

                // Include relationships
                'campaign'       => $item->campaign,
            ];
        });

        return $plans;
    }

    public function purchase(Request $request) {
        $validator = validator($request->all(), [
            'plan_id' => 'required|integer',
        ]);

        if ($validator->fails()) return responseError('validation_error', $validator->errors());

        $plan = Plan::active()->with('campaign', function ($query) {
            $query->active();
        })->find($request->plan_id);

        if (!$plan) {
            $notify[] = 'Plan not found';
            return responseError('not_found', $notify);
        }

        try {
            esimService()->fetchSinglePlan($plan);
        } catch (\Exception $e) {
            $notify[] = $e->getMessage();
            return responseError('validation_error', $notify);
        }

        $user = auth()->user();
        $order = new Order();
        $order->user_id = $user->id;
        $order->order_number = getTrx(10);
        $order->save();

        $price = $plan->converted_price;
        $discount = 0;

        if ($plan->campaign) {
            $discount = $price * $plan->campaign->discount / 100;
            $price = $price - $discount;
        }

        $orderItem = new OrderItem();
        $orderItem->plan_id = $plan->id;
        $orderItem->order_id = $order->id;
        $orderItem->campaign_id = $plan->campaign?->id ?? 0;
        $orderItem->plan_retail_price = $plan->converted_price;
        $orderItem->campaign_percentage = $plan->campaign?->discount ?? 0;
        $orderItem->discount = $discount;
        $orderItem->price  = $price;
        $orderItem->save();

        $order->total_amount = $orderItem->price;
        $order->save();

        $order = Order::select('id', 'user_id', 'total_amount', 'status', 'created_at')
            ->where('user_id', $user->id)
            ->where('id', $order->id)
            ->with(['orderItem:id,order_id,plan_id,campaign_id,plan_retail_price,campaign_percentage,discount,price,is_esim_created,created_at'])
            ->first();


        $notify[] = 'Order created successfully';
        return responseSuccess('order_created', $notify, [
            'order' => $order
        ]);
    }
}
