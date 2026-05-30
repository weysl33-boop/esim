<?php

namespace App\Http\Controllers\Api;

use App\Constants\Status;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Gateway\PaymentController;
use App\Models\Deposit;
use App\Models\GatewayCurrency;
use App\Models\Order;
use Illuminate\Http\Request;

class OrderController extends Controller {
    public function orders($scope) {
        $orders = Order::$scope()->where('user_id', auth()->id())
            ->select('id', 'total_amount', 'status', 'created_at')
            ->with(['orderItem:id,order_id,plan_id,price,is_esim_created,created_at'])
            ->orderBy('id', 'DESC')
            ->apiQuery();

        $notify[] = ucfirst($scope) . ' Orders';
        return responseSuccess('orders_fetched', $notify, [
            'orders' => $orders
        ]);
    }

    public function detail($id) {
        $order = Order::where('user_id', auth()->id())
            ->select('id', 'total_amount', 'status', 'created_at')
            ->with('orderItem:id,order_id,plan_id,price,is_esim_created,created_at')
            ->find($id);

        if (!$order) {
            $notify[] = 'Order not found';
            return responseError('not_found', $notify);
        }

        $payment = Deposit::where('order_id', $order->id)
            ->where('user_id', auth()->id())
            ->select('amount', 'method_currency', 'method_code', 'created_at')
            ->with('gateway:id,name,code')
            ->first();

        $notify[] = 'Order details';
        return responseSuccess('fetched_order', $notify, [
            'order' => $order,
            'payment_info' => $payment
        ]);
    }

    public function payment(Request $request) {
        $validator = validator($request->all(), [
            'gateway'       => 'required',
            'currency'      => 'required',
            'order_id'      => 'required|integer'
        ]);

        if ($validator->fails()) return responseError('validation_error', $validator->errors());

        $user = auth()->user();
        $order = Order::initiated()->where('user_id', $user->id)->with('user', 'orderItem.plan.esimProvider')->find($request->order_id);

        if (!$order) {
            $notify[] = 'Order not found';
            return responseError('not_found', $notify);
        }

        // for gateway payment
        if ($request->gateway != 'main-balance') {
            $gate = GatewayCurrency::whereHas('method', function ($gate) {
                $gate->where('status', Status::ENABLE);
            })->where('method_code', $request->gateway)
                ->where('currency', $request->currency)
                ->first();

            if (!$gate) {
                $notify[] = 'Invalid gateway';
                return responseError('invalid_gateway', $notify);
            }

            if ($gate->min_amount > $order->total_amount || $gate->max_amount < $order->total_amount) {
                $notify[] = 'Please follow gateway limit';
                return responseError('invalid_limit', $notify);
            }

            $deposit = PaymentController::insertDepositData($gate, $order->total_amount, $order->id, null, 1);

            $notify[] = 'Payment initiated successfully';
            return responseSuccess('deposit_initiated', $notify, [
                'redirect_url'  => route('deposit.app.confirm', encrypt($deposit->id))
            ]);
        }

        if ($order->total_amount > $user->balance) {
            $notify[] = 'Insufficient balance';
            return responseError('insufficient_balance', $notify);
        }

        try {
            esimService()->confirmPurchase($order);
        } catch (\Exception $e) {
            $notify[] = $e->getMessage();
            return responseError('order_confirmation_failed', $notify);
        }

        $notify[] = 'Order completed successfully';
        return responseSuccess('order_completed', $notify);
    }
}
