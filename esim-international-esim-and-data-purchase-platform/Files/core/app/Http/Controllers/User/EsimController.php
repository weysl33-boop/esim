<?php

namespace App\Http\Controllers\User;

use App\Constants\Status;
use App\Http\Controllers\Controller;
use App\Models\Currency;
use App\Models\Esim;
use App\Models\Topup;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class EsimController extends Controller {
    public function active() {
        $pageTitle = 'Active eSIMs';
        $esims = Esim::active()->where('user_id', auth()->id())->with('orderItem.plan')->orderBy('id', 'DESC')->paginate(getPaginate());
        return view('Template::user.esim.index', compact('pageTitle', 'esims'));
    }

    public function expired() {
        $pageTitle = 'Expired eSIMs';
        $esims = Esim::expired()->where('user_id', auth()->id())->with('orderItem.plan')->orderBy('id', 'DESC')->paginate(getPaginate());
        return view('Template::user.esim.index', compact('pageTitle', 'esims'));
    }

    public function detail($id) {
        $esim = Esim::where('user_id', auth()->id())->with('orderItem.plan', 'orderItem.plan.countries', 'orderItem.order.deposit')->findOrFail($id);

        $pageTitle = 'eSIM Details';
        $coverageCountries = $esim->orderItem->plan->countries;
        return view('Template::user.esim.detail', compact('pageTitle', 'esim', 'coverageCountries'));
    }

    public function getQrCode($id) {
        $esim = Esim::active()->where('user_id', auth()->id())->findOrFail($id);

        return response()->json([
            'status' => 'ACTIVE',
            'qr'     => cryptoQR($esim->qr_code),
        ]);
    }

    public function checkCapacity(Request $request) {
        $validator = Validator::make($request->all(), [
            'esim_id' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status'  => 'error',
                'message' => $validator->errors()->all(),
            ]);
        }

        $esim = Esim::with('orderItem.plan.esimProvider')->where('user_id', auth()->id())->find($request->esim_id);
        if (!$esim) {
            return response()->json([
                'status'  => 'error',
                'message' => 'eSIM not found.',
            ]);
        }

        $response = esimService()->remainingCapacity($esim);

        if (isset($response['error'])) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Something went wrong.',
            ]);
        }

        return response()->json([
            'status' => 'success',
            'data'   => [
                'remaining'     => $response['remaining_capacity'] ?? '--',
                'plan_expiry'   => $response['plan_expiry'] ?? '--',
                'esim_expiry'   => $response['esim_expiry'] ?? '--',
                'phone'         => $esim->phone_number ?? '--',
                'remaining_sms'  => $response['remaining_sms'] ?? '--',
                'remaining_voice' => $response['remaining_voice'] ?? '--',
                'network_speed' => $esim->orderItem->plan->network_speed ?? '--'
            ]
        ]);
    }

    public function cancel($id) {
        $user = auth()->user();
        $esim = Esim::active()->with('orderItem.plan')->where('user_id', $user->id)->findOrFail($id);

        if (!$esim->isRefundable()) {
            $notify[] = ['error', 'The eSIM is not refundable'];
            return back()->withNotify($notify);
        }

        if ($user->balance < gs('refund_charge')) {
            $notify[] = ['error', 'Insufficient balance to pay the refund charge'];
            return back()->withNotify($notify);
        }

        $response = esimService()->cancelEsim($esim);

        if (isset($response['status']) && $response['status'] == 'success') {
            $esim->status = Status::ESIM_CANCELED;
            $esim->save();

            $user->balance -= gs('refund_charge');
            $user->save();

            $transaction = new Transaction();
            $transaction->user_id = $user->id;
            $transaction->amount = gs('refund_charge');
            $transaction->post_balance = $user->balance;
            $transaction->trx_type = '-';
            $transaction->details = 'Refund charge for eSIM cancellation - ' . $esim->iccid;
            $transaction->trx = getTrx();
            $transaction->remark = 'refund_charge';
            $transaction->save();

            notify($user, 'ESIM_REFUNDED', [
                'iccid'         => $esim->iccid,
                'refund_charge' => showAmount(gs('refund_charge'), currencyFormat: false),
                'trx'           => $transaction->trx,
                'post_balance'  => showAmount($user->balance, currencyFormat: false)
            ]);

            $notify[] = ['success', 'eSIM cancelled successfully'];
            return back()->withNotify($notify);
        } else {
            $notify[] = ['error', $response['message']];
            return back()->withNotify($notify);
        }
    }

    public function topupHistory() {
        $pageTitle = 'eSIM Topup History';
        $topups = Topup::where('status', '!=', Status::TOPUP_INITIATED)->where('user_id', auth()->id())->with('esim')->orderBy('id', 'DESC')->paginate(getPaginate());
        return view('Template::user.esim.topup_history', compact('pageTitle', 'topups'));
    }

    public function topupForm($id) {
        $esim = Esim::active()->with('orderItem.plan')->where('user_id', auth()->id())->findOrFail($id);

        if (!$esim->isReloadable()) {
            $notify[] = ['error', 'The eSIM cannot be topped up'];
            return back()->withNotify($notify);
        }

        $pageTitle = 'Topup eSIM';
        $response = $this->getTopupPlans($esim);

        if ($response['status'] == 'error') {
            $notify[] = ['error', $response['message']];
            return back()->withNotify($notify);
        }

        $plans = $response['data'];
        return view('Template::user.esim.topup', compact('pageTitle', 'esim', 'plans'));
    }

    public function topupSubmit(Request $request, $id) {
        $request->validate([
            'uid' => 'required',
        ], [
            'uid.required' => 'Please select a topup plan',
        ]);

        $user = auth()->user();
        $esim = Esim::active()->with('orderItem.plan')->where('user_id', $user->id)->findOrFail($id);

        if (!$esim->isReloadable()) {
            $notify[] = ['error', 'The eSIM cannot be topped up'];
            return back()->withNotify($notify);
        }

        $response = $this->getTopupPlans($esim);
        if ($response['status'] == 'error') {
            $notify[] = ['error', $response['message']];
            return back()->withNotify($notify);
        }

        $plans = array_column($response['data'], null, 'uid');
        $selectedPlan = $plans[$request->uid] ?? null;

        if (!$selectedPlan) {
            $notify[] = ['error', 'Selected topup plan not found'];
            return back()->withNotify($notify);
        }

        $topup = new Topup();
        $topup->name = $selectedPlan['name'];
        $topup->trx = getTrx(10);
        $topup->user_id = $user->id;
        $topup->esim_id = $esim->id;
        $topup->unique_id = $request->uid;
        $topup->data_volume = $selectedPlan['data_volume'] ?? 0;
        $topup->voice_quantity = $selectedPlan['voice_quantity'] ?? 0;
        $topup->sms_quantity = $selectedPlan['sms_quantity'] ?? 0;
        $topup->validity = $selectedPlan['validity'] ?? 0;
        $topup->price = $selectedPlan['price'];
        $topup->save();

        return to_route('user.deposit.index', ['topup_id' => encrypt($topup->id)]);
    }

    private function getTopupPlans($esim) {
        $plans = session()->get('topup_plans_' . $esim->id, []);
        if ($plans) {
            return [
                'status' => 'success',
                'data' => $plans,
            ];
        }

        $response = esimService()->getTopupPlans($esim);
        if (isset($response['status']) && $response['status'] == 'error') {
            return [
                'status' => 'error',
                'message' => $response['error'],
            ];
        }

        $plans = $response['data'];

        foreach ($plans as &$plan) {
            if (gs('cur_text') == $plan['currency']) {
                $price = $plan['price'] + gs('additional_topup_price');
            } else {
                $currency = Currency::where('code', $plan['currency'])->first();
                $price = $currency->baseCurrencyAmount($plan['price']) + gs('additional_topup_price');
            }

            $plan['price'] = $price;
        }

        session()->put('topup_plans_' . $esim->id, $plans);

        return [
            'status' => 'success',
            'data' => $plans,
        ];
    }
}
