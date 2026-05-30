<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Esim;
use App\Constants\ColumnSelection;
use App\Constants\Status;
use App\Models\Transaction;

class EsimController extends Controller {
    public function esims($scope) {
        $esims = Esim::$scope()
            ->with([
                'orderItem:id,order_id,plan_id',
                'orderItem.plan:id,name,package_type,data_volume,voice_quantity,sms_quantity,retail_price,reloadable,refundable,area_coverage,region_id',
                'orderItem.plan.region:id,name,region_image',
                'orderItem.plan.countries:id,name,image'
            ])
            ->where('user_id', auth()->id())
            ->select(ColumnSelection::ESIM_MODEL)
            ->apiQuery();

        $esims->getCollection()->transform(function ($esim) {
            $esim->price = $esim->orderItem->plan->retail_price;
            $esim->readable_data_volume = $esim->orderItem->plan->readableDataVolume;
            $esim->readable_voice_quantity = $esim->orderItem->plan->readableVoiceQuantity;
            $esim->readable_sms_quantity = $esim->orderItem->plan->readableSmsQuantity;
            $esim->formatted_expiry_date = showDateTime($esim->expiry_date, 'd M, Y');

            $image = null;
            if ($esim->orderItem->plan->area_coverage == 'local') {
                $image = $esim->orderItem->plan->countries->first()->image ?? null;
                if ($image) $image = getImage(getFilePath('countryFlag') . '/' . $image, getFileSize('countryFlag'));
            } elseif ($esim->orderItem->plan->area_coverage == 'continental') {
                $image = $esim->orderItem->plan->region->region_image ?? null;
                if ($image) $image = getImage(getFilePath('regionImage'), $image, getFileSize('regionImage'));
            }

            $esim->image = $image;
            return $esim;
        });

        $notify[] = ucfirst($scope) . ' eSIMs';
        return responseSuccess('fetched_esim_data', $notify, [
            'esims' => $esims
        ]);
    }

    public function detail($id) {
        $esim = Esim::with([
            'orderItem:id,order_id,plan_id',
            'orderItem.plan:id,name,package_type,data_volume,voice_quantity,sms_quantity,retail_price,reloadable,refundable,esim_provider_id'
        ])
            ->where('user_id', auth()->id())
            ->select(ColumnSelection::ESIM_MODEL)
            ->find($id);

        if (!$esim) {
            $notify[] = 'eSIM not found.';
            return responseError('esim_not_found', $notify);
        }

        $esim->is_reloadable = $esim->isReloadable();
        $esim->is_refundable = $esim->isRefundable();
        $esim->price = $esim->orderItem->plan->retail_price;
        $esim->readable_data_volume = $esim->orderItem->plan->readableDataVolume;
        $esim->readable_voice_quantity = $esim->orderItem->plan->readableVoiceQuantity;
        $esim->readable_sms_quantity = $esim->orderItem->plan->readableSmsQuantity;
        $esim->formatted_expiry_date = showDateTime($esim->expiry_date, 'd M, Y');

        try {
            $esim->remaining = esimService()->remainingCapacity($esim);
        } catch (\Exception $e) {
            $esim->remaining = null;
        }

        $notify[] = 'eSIM Detail';
        return responseSuccess('fetched_esim_detail', $notify, [
            'esim' => $esim
        ]);
    }

    public function checkCapacity($id) {
        $esim = Esim::with('orderItem.plan.esimProvider')->where('user_id', auth()->id())->find($id);
        if (!$esim) {
            $notify[] = 'eSIM not found.';
            return responseError('esim_not_found', $notify);
        }

        $response = esimService()->remainingCapacity($esim);

        if (isset($response['error'])) {
            $notify[] = 'Something went wrong';
            return responseError('esim_capacity_error', $notify);
        }

        $notify = 'eSIM capacity fetched successfully';
        return responseSuccess('esim_capacity_fetched', $notify, [
            'remaining'     => $response['remaining_capacity'] ?? '--',
            'plan_expiry'   => $response['plan_expiry'] ?? '--',
            'esim_expiry'   => $response['esim_expiry'] ?? '--',
            'phone'         => $esim->phone_number ?? '--',
            'remaining_sms'  => $response['remaining_sms'] ?? '--',
            'remaining_voice' => $response['remaining_voice'] ?? '--',
            'network_speed' => $esim->orderItem->plan->network_speed ?? '--'
        ]);
    }

    public function cancel($id) {
        $user = auth()->user();
        $esim = Esim::active()->where('user_id', $user->id)->find($id);
        if (!$esim) {
            $notify[] = 'eSIM not found';
            return responseError('esim_not_found', $notify);
        }

        if (!$esim->isRefundable()) {
            $notify[] = 'This eSIM is not refundable';
            return responseError('esim_not_refundable', $notify);
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

            $notify[] = 'eSIM cancelled successfully';
            return responseSuccess('esim_cancelled', $notify);
        } else {
            $notify[] = $response['message'];
            return responseError('esim_cancellation_failed', $notify);
        }
    }
}
