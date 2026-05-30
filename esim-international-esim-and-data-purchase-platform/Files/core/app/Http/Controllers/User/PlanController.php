<?php

namespace App\Http\Controllers\User;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Plan;
use Illuminate\Http\Request;

class PlanController extends Controller {

    public function purchase(Request $request) {
        $request->validate([
            'plan_id' => 'required|integer',
        ]);

        $plan = Plan::active()->with('campaign', function ($query) {
            $query->active();
        })->findOrFail($request->plan_id);

        $user = auth()->user();

        esimService()->fetchSinglePlan($plan);

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

        return to_route('user.order.payment', encrypt($order->id));
    }
}
