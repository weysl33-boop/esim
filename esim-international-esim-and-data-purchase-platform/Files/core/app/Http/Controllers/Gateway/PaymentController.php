<?php

namespace App\Http\Controllers\Gateway;

use App\Constants\Status;
use App\Http\Controllers\Controller;
use App\Lib\FormProcessor;
use App\Models\AdminNotification;
use App\Models\Deposit;
use App\Models\GatewayCurrency;
use App\Models\Order;
use App\Models\Topup;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Http\Request;

class PaymentController extends Controller {
    public function deposit() {
        $gatewayCurrency = GatewayCurrency::whereHas('method', function ($gate) {
            $gate->where('status', Status::ENABLE);
        })->with('method')->orderby('name')->get();

        $pageTitle = 'Deposit Methods';
        $topup = null;
        if (request()->topup_id) {
            try {
                $id = decrypt(request()->topup_id);
                $topup = Topup::where('status', Status::TOPUP_INITIATED)->where('user_id', auth()->id())->findOrFail($id);
            } catch (\Throwable $th) {
                abort(404);
            }

            $pageTitle = 'Payment Methods';
        }

        return view('Template::user.payment.deposit', compact('gatewayCurrency', 'pageTitle', 'topup'));
    }

    public function depositInsert(Request $request) {
        $request->validate([
            'amount'   => 'required|numeric|gt:0',
            'gateway'  => 'required',
            'currency' => 'required',
            'topup_id' => 'nullable',
        ]);

        $topup = null;
        $amount = $request->amount;
        $user = auth()->user();

        if ($request->topup_id) {
            $topup = Topup::where('status', Status::TOPUP_INITIATED)->where('user_id', $user->id)->with('esim.orderItem.plan', 'user')->find($request->topup_id);

            if (!$topup) {
                $notify[] = ['error', 'Topup not found'];
                return to_route('user.esim.topups')->withNotify($notify);
            }

            $amount = $topup->price;

            if ($request->gateway == 'main-balance') {
                if ($user->balance < $amount) {
                    $notify[] = ['error', 'Insufficient balance'];
                    return to_route('user.esim.topups')->withNotify($notify);
                }

                $response = esimService()->topup($topup);
                if (isset($response['status']) && $response['status'] == 'error') {
                    $notify[] = ['error', $response['message']];
                    return to_route('user.esim.topups')->withNotify($notify);
                }

                $notify[] = ['success', 'Topup completed successfully'];
                return to_route('user.esim.topups')->withNotify($notify);
            }
        }

        $gate = GatewayCurrency::whereHas('method', function ($gate) {
            $gate->where('status', Status::ENABLE);
        })->where('method_code', $request->gateway)->where('currency', $request->currency)->first();

        if (!$gate) {
            $notify[] = ['error', 'Invalid gateway'];
            return back()->withNotify($notify);
        }

        if ($gate->min_amount > $amount || $gate->max_amount < $amount) {
            $notify[] = ['error', 'Please follow deposit limit'];
            return back()->withNotify($notify);
        }

        self::insertDepositData($gate, $amount, topup: $topup);
        return to_route('user.deposit.confirm');
    }

    public static function insertDepositData($gate, $amount, $orderId = 0, $topup = null, $fromApi = 0) {
        $charge      = $gate->fixed_charge + ($amount * $gate->percent_charge / 100);
        $payable     = $amount + $charge;
        $finalAmount = $payable * $gate->rate;

        if ($orderId) {
            $successUrl = route('user.order.detail', $orderId);
        } elseif ($topup) {
            $successUrl = route('user.esim.topups');
        } else {
            $successUrl = route('user.deposit.history');
        }

        $data                  = new Deposit();
        $data->user_id         = auth()->id();
        $data->order_id        = $orderId;
        $data->topup_id        = $topup ? $topup->id : 0;
        $data->method_code     = $gate->method_code;
        $data->method_currency = strtoupper($gate->currency);
        $data->amount          = $amount;
        $data->charge          = $charge;
        $data->rate            = $gate->rate;
        $data->final_amount    = $finalAmount;
        $data->btc_amount      = 0;
        $data->btc_wallet      = "";
        $data->trx             = getTrx();
        $data->success_url     = $successUrl;
        $data->failed_url      = route('user.deposit.history');
        $data->from_api        = $fromApi;
        $data->save();

        session()->put('Track', $data->trx);
        return $data;
    }

    public function appDepositConfirm($hash) {
        try {
            $id = decrypt($hash);
        } catch (\Exception $ex) {
            abort(404);
        }
        $data = Deposit::where('id', $id)->where('status', Status::PAYMENT_INITIATE)->orderBy('id', 'DESC')->firstOrFail();
        $user = User::findOrFail($data->user_id);
        auth()->login($user);
        session()->put('Track', $data->trx);
        return to_route('user.deposit.confirm');
    }

    public function depositConfirm() {
        $track   = session()->get('Track');
        $deposit = Deposit::where('trx', $track)->where('status', Status::PAYMENT_INITIATE)->orderBy('id', 'DESC')->with('gateway')->firstOrFail();

        if ($deposit->method_code >= 1000) {
            return to_route('user.deposit.manual.confirm');
        }

        $dirName = $deposit->gateway->alias;
        $new     = __NAMESPACE__ . '\\' . $dirName . '\\ProcessController';

        $data = $new::process($deposit);
        $data = json_decode($data);

        if (isset($data->error)) {
            $notify[] = ['error', $data->message];
            return back()->withNotify($notify);
        }
        if (isset($data->redirect)) {
            return redirect($data->redirect_url);
        }

        if (isset($data->session)) {
            $deposit->btc_wallet = $data->session->id;
            $deposit->save();
        }

        $pageTitle = 'Payment Confirm';
        return view("Template::$data->view", compact('data', 'pageTitle', 'deposit'));
    }

    public static function userDataUpdate($deposit, $isManual = null) {
        if ($deposit->status == Status::PAYMENT_INITIATE || $deposit->status == Status::PAYMENT_PENDING) {
            $deposit->status = Status::PAYMENT_SUCCESS;
            $deposit->save();

            $user = User::find($deposit->user_id);
            $user->balance += $deposit->amount;
            $user->save();

            $methodName = $deposit->methodName();

            $transaction               = new Transaction();
            $transaction->user_id      = $deposit->user_id;
            $transaction->amount       = $deposit->amount;
            $transaction->post_balance = $user->balance;
            $transaction->charge       = $deposit->charge;
            $transaction->trx_type     = '+';
            $transaction->details      = 'Deposit Via ' . $methodName;
            $transaction->trx          = $deposit->trx;
            $transaction->remark       = 'deposit';
            $transaction->save();

            notify($user, $isManual ? 'DEPOSIT_APPROVE' : 'DEPOSIT_COMPLETE', [
                'method_name'     => $methodName,
                'method_currency' => $deposit->method_currency,
                'method_amount'   => showAmount($deposit->final_amount, currencyFormat: false),
                'amount'          => showAmount($deposit->amount, currencyFormat: false),
                'charge'          => showAmount($deposit->charge, currencyFormat: false),
                'rate'            => showAmount($deposit->rate, currencyFormat: false),
                'trx'             => $deposit->trx,
                'post_balance'    => showAmount($user->balance, currencyFormat: false),
            ]);

            if (!$isManual) {
                $adminNotification            = new AdminNotification();
                $adminNotification->user_id   = $user->id;
                $adminNotification->title     = 'Deposit successful via ' . $methodName;
                $adminNotification->click_url = urlPath('admin.deposit.successful');
                $adminNotification->save();
            }

            if ($deposit->order_id) {
                $order = Order::with('user', 'orderItem.plan')->find($deposit->order_id);

                try {
                    esimService()->confirmPurchase($order);
                } catch (\Exception $e) {
                }
            }

            if ($deposit->topup_id) {
                $topup = Topup::with('esim', 'user')->find($deposit->topup_id);

                try {
                    esimService()->topup($topup);
                } catch (\Throwable $th) {
                }
            }
        }
    }

    public function manualDepositConfirm() {
        $track = session()->get('Track');
        $data  = Deposit::with('gateway')->where('status', Status::PAYMENT_INITIATE)->where('trx', $track)->first();
        abort_if(!$data, 404);

        if ($data->method_code > 999) {
            if ($data->plan_id) {
                $pageTitle = 'Confirm Payment';
            } else {
                $pageTitle = 'Confirm Deposit';
            }
            $method  = $data->gatewayCurrency();
            $gateway = $method->method;
            return view('Template::user.payment.manual', compact('data', 'pageTitle', 'method', 'gateway'));
        }
        abort(404);
    }

    public function manualDepositUpdate(Request $request) {
        $track = session()->get('Track');
        $data  = Deposit::with('gateway')->where('status', Status::PAYMENT_INITIATE)->where('trx', $track)->first();
        abort_if(!$data, 404);

        $gatewayCurrency = $data->gatewayCurrency();
        $gateway         = $gatewayCurrency->method;
        $formData        = $gateway->form->form_data;

        $formProcessor  = new FormProcessor();
        $validationRule = $formProcessor->valueValidation($formData);
        $request->validate($validationRule);
        $userData = $formProcessor->processFormData($request, $formData);

        $data->detail = $userData;
        $data->status = Status::PAYMENT_PENDING;
        $data->save();

        $adminNotification            = new AdminNotification();
        $adminNotification->user_id   = $data->user->id;
        $adminNotification->title     = 'Deposit request from ' . $data->user->username;
        $adminNotification->click_url = urlPath('admin.deposit.details', $data->id);
        $adminNotification->save();

        if ($data->order_id) {
            $order = Order::initiated()->where('user_id', auth()->id())->find($data->order_id);
            $order->status = Status::ORDER_PENDING;
            $order->save();

            notify($data->user, 'PAYMENT_REQUEST', [
                'order_number'    => $order->order_number,
                'method_name'     => $data->gatewayCurrency()->name,
                'method_currency' => $data->method_currency,
                'method_amount'   => showAmount($data->final_amount, currencyFormat: false),
                'amount'          => showAmount($data->amount, currencyFormat: false),
                'charge'          => showAmount($data->charge, currencyFormat: false),
                'rate'            => showAmount($data->rate, currencyFormat: false),
                'trx'             => $data->trx,
            ]);

            $notify[] = ['success', 'Order payment request has been taken'];
            return to_route('user.order.pending')->withNotify($notify);
        }

        notify($data->user, 'DEPOSIT_REQUEST', [
            'method_name'     => $data->gatewayCurrency()->name,
            'method_currency' => $data->method_currency,
            'method_amount'   => showAmount($data->final_amount, currencyFormat: false),
            'amount'          => showAmount($data->amount, currencyFormat: false),
            'charge'          => showAmount($data->charge, currencyFormat: false),
            'rate'            => showAmount($data->rate, currencyFormat: false),
            'trx'             => $data->trx,
        ]);

        $notify[] = ['success', 'Your deposit request has been taken'];
        return to_route('user.deposit.history')->withNotify($notify);
    }
}
