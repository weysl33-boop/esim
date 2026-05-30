<?php

namespace App\Http\Controllers\Api;

use App\Constants\ColumnSelection;
use App\Constants\Status;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Gateway\PaymentController;
use App\Models\Currency;
use App\Models\Esim;
use App\Models\GatewayCurrency;
use App\Models\Topup;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TopupController extends Controller {
    public function topupHistory($esimId = null) {
        $columns = implode(',', ColumnSelection::ESIM_MODEL);
        $topups  = Topup::where('status', '!=', Status::TOPUP_INITIATED)
            ->where('user_id', auth()->id())
            ->when($esimId, function ($query, $esimId) {
                return $query->where('esim_id', $esimId);
            })
            ->with('esim:' . $columns)
            ->select(ColumnSelection::TOPUP_MODEL)
            ->apiQuery();

        $notify[] = 'eSIM Top-up History';
        return responseSuccess('esim_topup_history', $notify, [
            'topups' => $topups
        ]);
    }

    public function topupPlans($id) {
        $esim = Esim::where('user_id', auth()->id())->with('orderItem.plan')->find($id);
        if (!$esim) {
            $notify[] = 'eSIM not found';
            return responseError('esim_not_found', $notify);
        }

        if (!$esim->isReloadable()) {
            $notify[] = 'The eSIM cannot be topped up';
            return responseError('esim_not_reloadable', $notify);
        }

        try {
            $response = $this->getTopupPlans($esim);

            if ($response['status'] == 'error') {
                $notify[] = $response['message'];
                return responseError('esim_topup_plans_error', $notify);
            }

            $notify[] = 'eSIM Top-up Plans Fetched Successfully';

            return responseSuccess('esim_topup_plans_fetched', $notify, [
                'plans' => $response['data']
            ]);
        } catch (\Exception $e) {
            $notify[] = 'Something went wrong';
            return responseError('esim_topup_plans_error', $notify);
        }
    }

    public function topupSubmit(Request $request, $id) {
        $validator = Validator::make($request->all(), [
            'uid' => 'required'
        ], [
            'uid.required' => 'Please select a topup plan',
        ]);

        if ($validator->fails()) responseError('validation_error', $validator->errors());

        $user = auth()->user();
        $esim = Esim::active()->with('orderItem.plan')->where('user_id', $user->id)->find($id);

        if (!$esim) {
            $notify[] = 'eSIM not found.';
            return responseError('esim_not_found', $notify);
        }

        if (!$esim->isReloadable()) {
            $notify[] = 'The eSIM cannot be topped up';
            return responseError('esim_not_reloadable', $notify);
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

        $topup                 = new Topup();
        $topup->name           = $selectedPlan['name'];
        $topup->trx            = getTrx(10);
        $topup->user_id        = $user->id;
        $topup->esim_id        = $esim->id;
        $topup->unique_id      = $request->uid;
        $topup->data_volume    = $selectedPlan['data_volume'] ?? 0;
        $topup->voice_quantity = $selectedPlan['voice_quantity'] ?? 0;
        $topup->sms_quantity   = $selectedPlan['sms_quantity'] ?? 0;
        $topup->validity       = $selectedPlan['validity'] ?? 0;
        $topup->price          = $selectedPlan['price'];
        $topup->save();

        $notify[] = 'eSIM Top-up Initiated Successfully';
        return responseSuccess('esim_topup_initiated', $notify, [
            'topup' => $topup->refresh()->only(['id', 'name', 'data_volume', 'voice_quantity', 'sms_quantity', 'validity', 'price', 'status', 'created_at']),
        ]);
    }

    public function topupPayment(Request $request, $id) {
        $validator = Validator::make($request->all(), [
            'gateway' => 'required',
            'currency' => 'required',
        ]);

        if ($validator->fails()) responseError('validation_error', $validator->errors());

        $user = auth()->user();
        $topup = Topup::where('user_id', $user->id)->where('status', Status::TOPUP_INITIATED)->find($id);
        if (!$topup) {
            $notify[] = 'Top-up not found.';
            return responseError('topup_not_found', $notify);
        }

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

            if ($gate->min_amount > $topup->price || $gate->max_amount < $topup->price) {
                $notify[] = 'Please follow gateway limit';
                return responseError('invalid_limit', $notify);
            }

            $deposit = PaymentController::insertDepositData($gate, $topup->price, 0, $topup, 1);

            $notify[] = 'Payment initiated successfully';
            return responseSuccess('deposit_initiated', $notify, [
                'redirect_url'  => route('deposit.app.confirm', encrypt($deposit->id))
            ]);
        }

        if ($topup->price > $user->balance) {
            $notify[] = 'Insufficient balance';
            return responseError('insufficient_balance', $notify);
        }

        try {
            esimService()->topup($topup);
        } catch (\Exception $e) {
            $notify[] = $e->getMessage();
            return responseError('topup_payment_failed', $notify);
        }

        $notify[] = 'Top-up completed successfully';
        return responseSuccess('topup_completed', $notify);
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
