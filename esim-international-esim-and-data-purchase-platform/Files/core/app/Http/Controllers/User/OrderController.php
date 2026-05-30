<?php

namespace App\Http\Controllers\User;

use App\Constants\Status;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Gateway\PaymentController;
use App\Models\GatewayCurrency;
use App\Models\Order;
use Illuminate\Http\Request;
use Throwable;

class OrderController extends Controller {
    public function pending() {
        $pageTitle = 'Pending Orders';
        $orders = Order::pending()->where('user_id', auth()->id())->orderBy('id', 'DESC')->paginate(getPaginate());
        return view('Template::user.order.index', compact('pageTitle', 'orders'));
    }

    public function completed() {
        $pageTitle = 'Completed Orders';
        $orders = Order::completed()->where('user_id', auth()->id())->orderBy('id', 'DESC')->paginate(getPaginate());
        return view('Template::user.order.index', compact('pageTitle', 'orders'));
    }

    public function detail($id) {
        $order = Order::where('user_id', auth()->id())
            ->with('deposit', 'orderItem.plan', 'orderItem.esim')
            ->findOrFail($id);

        $pageTitle = 'Order Details';
        return view('Template::user.order.detail', compact('pageTitle', 'order'));
    }

    public function payment($id) {
        try {
            $id = decrypt($id);
            $order = Order::initiated()->where('user_id', auth()->id())->with('orderItem.plan')->findOrFail($id);
        } catch (\Exception $e) {
            $notify[] = ['error', 'Invalid order!'];
            return to_route('destination')->withNotify($notify);
        }

        $gatewayCurrency = GatewayCurrency::where(function ($query) use ($order) {
            $query->where('min_amount', '<=', $order->total_amount)->where('max_amount', '>=', $order->total_amount);
        })->whereHas('method', function ($gate) {
            $gate->where('status', Status::ENABLE);
        })->with('method')->orderBy('name')->get();

        $pageTitle = 'Payment Methods';
        return view('Template::user.order.payment', compact('pageTitle', 'gatewayCurrency',  'order'));
    }

    public function paymentInitiate(Request $request) {
        $request->validate([
            'gateway'       => 'required',
            'currency'      => 'required',
            'order_id'      => 'required|integer|exists:orders,id',
        ]);

        $user   = auth()->user();
        $order = Order::initiated()->where('user_id', $user->id)->with('user', 'orderItem.plan.esimProvider')->find($request->order_id);

        if (!$order) {
            $notify[] = ['error', 'Order not found'];
            return back()->withNotify($notify);
        }

        // for gateway payment
        if ($request->gateway != 'main-balance') {
            $gate = GatewayCurrency::whereHas('method', function ($gate) {
                $gate->where('status', Status::ENABLE);
            })->where('method_code', $request->gateway)
                ->where('currency', $request->currency)
                ->first();

            if (!$gate) {
                $notify[] = ['error', 'Invalid gateway'];
                return back()->withNotify($notify);
            }

            if ($gate->min_amount > $order->total_amount || $gate->max_amount < $order->total_amount) {
                $notify[] = ['error', 'Please follow payment limit'];
                return back()->withNotify($notify);
            }

            PaymentController::insertDepositData($gate, $order->total_amount, $order->id);
            return to_route('user.deposit.confirm');
        }

        // for wallet payment
        if ($order->total_amount > $user->balance) {
            $notify[] = ['error', 'Insufficient balance'];
            return back()->withNotify($notify);
        }

        try {
            esimService()->confirmPurchase($order);
        } catch (Throwable $e) {
            $message = method_exists($e, 'getMessage') ? $e->getMessage() : 'Order confirmation failed';
            if (method_exists($e, 'errors')) {
                $errors = $e->errors();
                if (isset($errors['error'][0])) {
                    $message = $errors['error'][0];
                } elseif (!empty($errors)) {
                    $firstErrorGroup = reset($errors);
                    if (is_array($firstErrorGroup) && isset($firstErrorGroup[0])) {
                        $message = $firstErrorGroup[0];
                    }
                }
            }

            $notify[] = ['error', $message];
            return back()->withNotify($notify);
        }

        $notify[] = ['success', 'Order completed successfully'];
        return to_route('user.order.detail', $order->id)->withNotify($notify);
    }
}
