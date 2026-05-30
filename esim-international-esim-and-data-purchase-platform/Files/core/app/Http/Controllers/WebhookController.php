<?php

namespace App\Http\Controllers;

use App\Constants\Status;
use App\EsimProviders\EsimAccess;
use App\Models\OrderItem;
use Illuminate\Http\Request;

class WebhookController extends Controller {
    public function esimaccess(Request $request) {
        $allowedIps = config('webhook.esimaccess');
        $requestIp = $request->ip();

        if (!in_array($requestIp, $allowedIps)) {
            return response()->json([
                'error' => 'Unauthorized IP address.',
                'your_ip' => $requestIp,
            ], 403);
        }

        if (
            $request->notifyType == 'ORDER_STATUS' &&
            isset($request->content['orderStatus']) &&
            $request->content['orderStatus'] == 'GOT_RESOURCE'
        ) {
            $orderNo = $request->content['orderNo'];

            $orderItem = OrderItem::where('purchase_id', $orderNo)->with('order.user', 'plan.esimProvider')->first();

            if ($orderItem && $orderItem->plan && $orderItem->plan->esimProvider) {
                $provider = new EsimAccess($orderItem->plan->esimProvider);
                try {
                    $response = $provider->retriveEsimByOrderNumber($orderNo);

                    if ($response['esimStatus'] == 'GOT_RESOURCE') {
                        $data = [
                            'serial_number' => $response['imsi'],
                            'iccid' => $response['iccid'],
                            'qr_code_image' => $response['qrCodeUrl'],
                            'expiry_date' => now()->addDays($response['totalDuration']),
                            'info' => [
                                'pin' => $response['pin'],
                                'puk' => $response['puk'],
                                'apn' => $response['apn'],
                                'esimTranNo' => $response['esimTranNo']
                            ]
                        ];

                        esimService()->createEsim($orderItem->order, $data);

                        $orderItem->is_esim_created = Status::YES;
                        $orderItem->save();
                    }
                } catch (\Exception $e) {
                    \Log::error('Webhook exception: ' . $e->getMessage());
                }
            }
        }

        return response()->json(['status' => 'OK']);
    }
}
