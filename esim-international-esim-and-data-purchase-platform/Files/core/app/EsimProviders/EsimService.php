<?php

namespace App\EsimProviders;

use App\Constants\Status;
use App\Models\Currency;
use App\Models\Esim;
use App\Models\EsimProvider;
use App\Models\Order;
use App\Models\Transaction;
use Exception;
use Illuminate\Validation\ValidationException;

class EsimService {
    private $providers;

    public function __construct() {
        $this->providers = EsimProvider::active()->get();
    }

    public function fetchRegions($slug) {
        $provider = $this->resolveProvider($slug);

        if (!method_exists($provider, 'fetchRegions')) {
            throw ValidationException::withMessages(['error' => 'The selected provider does\'t support region fetching.']);
        }

        try {
            return $provider->fetchRegions();
        } catch (Exception $e) {
            throw ValidationException::withMessages(['error' => $e->getMessage()]);
        }
    }

    public function fetchCountries($slug) {
        $provider = $this->resolveProvider($slug);

        if (!method_exists($provider, 'fetchCountries')) {
            throw ValidationException::withMessages(['error' => 'The selected provider does\'t support country fetching.']);
        }

        try {
            return $provider->fetchCountries();
        } catch (Exception $e) {
            throw ValidationException::withMessages(['error' => $e->getMessage()]);
        }
    }

    public function fetchPlans($slug) {
        $provider = $this->resolveProvider($slug);
        try {
            return $provider->fetchPlans();
        } catch (Exception $e) {
            throw ValidationException::withMessages(['error' => $e->getMessage()]);
        }
    }

    public function fetchGlobalPlans($slug) {
        $provider = $this->resolveProvider($slug);
        try {
            return $provider->fetchGlobalPlans();
        } catch (Exception $e) {
            throw ValidationException::withMessages(['error' => $e->getMessage()]);
        }
    }

    public function fetchContinentalPlans($slug) {
        $provider = $this->resolveProvider($slug);
        try {
            return $provider->fetchContinentalPlans();
        } catch (Exception $e) {
            throw ValidationException::withMessages(['error' => $e->getMessage()]);
        }
    }

    public function fetchCountryPlans($slug) {
        $provider = $this->resolveProvider($slug);
        try {
            return $provider->fetchCountryPlans();
        } catch (Exception $e) {
            throw ValidationException::withMessages(['error' => $e->getMessage()]);
        }
    }

    public function fetchSinglePlan($plan) {
        $provider = $this->resolveProvider($plan->esimProvider->slug);
        try {
            return $provider->fetchSinglePlan($plan);
        } catch (Exception $e) {
            $plan->status = Status::PLAN_PENDING;
            $plan->save();
            throw ValidationException::withMessages(['error' => 'The plan is currently unavailable']);
        }
    }

    public function remainingCapacity($esim) {
        $plan = $esim->orderItem->plan;
        $provider = $this->resolveProvider($plan->esimProvider->slug);
        try {
            return $provider->getRemainingCapacity($esim);
        } catch (\Exception $e) {
            return ['error' => $e->getMessage()];
        }
        return $response;
    }

    public function confirmPurchase($order) {
        $user = $order->user;

        $orderItem = $order->orderItem;
        $providerModel = $orderItem->plan->esimProvider;
        $provider = $this->resolveProvider($providerModel->slug);

        try {
            $response = $provider->purchasePlan($order);
        } catch (Exception $e) {
            throw ValidationException::withMessages(['error' => $e->getMessage()]);
        }

        $order->status = Status::ORDER_COMPLETED;
        $order->save();

        $paidAmount  = $response['paid_amount'] ?? 0;
        $currency = Currency::where('api_currency', $providerModel->currency)->first();

        if ($currency) {
            $paidAmount = $currency->baseCurrencyAmount($paidAmount);
        }

        $orderItem->paid_price  = $paidAmount;
        $orderItem->purchase_id = $response['purchase_id'] ?? null;

        if ($response['esim_processed']) {
            $this->createEsim($order, $response);
            $orderItem->is_esim_created = Status::ESIM_ACTIVE;
        }

        $orderItem->save();

        $user->balance -= $order->total_amount;
        $user->save();

        $transaction               = new Transaction();
        $transaction->user_id      = $user->id;
        $transaction->order_id     = $orderItem->order_id;
        $transaction->amount       = $order->total_amount;
        $transaction->post_balance = $user->balance;
        $transaction->trx_type     = '-';
        $transaction->details      = 'Payment completed for order ' . $order->order_number;
        $transaction->trx          = getTrx();
        $transaction->remark       = 'order_payment';
        $transaction->save();

        notify($user, 'PAYMENT_COMPLETED', [
            'order_number'  => $order->order_number,
            'plan'          => $orderItem->plan->name,
            'amount'        => showAmount($order->total_amount, currencyFormat: false),
            'trx'           => $transaction->trx,
        ]);

        $otherOrder = Order::where('user_id', $user->id)->where('id', '!=', $order->id)->exists();
        if (!$otherOrder) {
            userReferralCommission($user);
        }
    }

    public function createEsim($order, $data) {
        $plan = $order->orderItem->plan;
        $esim                     = new Esim();
        $esim->esim_provider_id   = $plan->esim_provider_id;
        $esim->user_id            = $order->user->id;
        $esim->order_item_id      = $order->orderItem->id;
        $esim->serial_number      = $data['serial_number'] ?? null;
        $esim->iccid              = $data['iccid'] ?? null;
        $esim->phone_number       = $data['phone_number'] ?? null;
        $esim->qr_code            = $data['qr_code'] ?? null;
        $esim->qr_code_image      = $data['qr_code_image'] ?? null;
        $esim->expiry_date        = $data['expiry_date'] ?? null;
        $esim->info               = $data['info'] ?? null;
        $esim->status             = Status::ESIM_ACTIVE;
        $esim->save();

        notify($order->user, 'ESIM_CREATED', [
            'order_number' => $order->order_number,
            'iccid'        => $esim->iccid,
            'phone_number' => $esim->phone_number ?? 'N/A',
            'expired_at'   => $esim->expiry_date,
            'plan_name'    => $plan->name
        ]);
    }

    public function cancelEsim($esim) {
        $plan = $esim->orderItem->plan;
        $provider = $this->resolveProvider($plan->esimProvider->slug);
        try {
            return $provider->cancelEsim($esim);
        } catch (\Exception $e) {
            return ['message' => $e->getMessage()];
        }
    }

    public function getTopupPlans($esim) {
        $plan = $esim->orderItem->plan;
        $provider = $this->resolveProvider($plan->esimProvider->slug);
        try {
            $response = $provider->getTopupPlans($esim);

            if (isset($response['status']) && $response['status'] == 'error') {
                return [
                    'status' => 'error',
                    'message' => $response['message']
                ];
            }

            return $response;
        } catch (\Exception $e) {
            return ['error' => $e->getMessage()];
        }
    }

    public function topup($topup) {
        $plan = $topup->esim->orderItem->plan;
        $provider = $this->resolveProvider($plan->esimProvider->slug);
        try {
            $response = $provider->topup($topup);
            if (isset($response['status']) && $response['status'] == 'success') {

                $topup->status = Status::TOPUP_COMPLETED;
                if (isset($response['info'])) {
                    $topup->info = $response['info'];
                }

                $topup->save();

                $user = $topup->user;
                $user->balance -= $topup->price;
                $user->save();

                $trnsaction = new Transaction();
                $trnsaction->user_id      = $user->id;
                $trnsaction->amount       = $topup->price;
                $trnsaction->post_balance = $user->balance;
                $trnsaction->trx_type     = '-';
                $trnsaction->details      = 'eSIM Topup - ' . $topup->esim->iccid;
                $trnsaction->trx          = getTrx();
                $trnsaction->remark       = 'esim_topup';
                $trnsaction->save();

                notify($user, 'ESIM_TOPUP_COMPLETED', [
                    'iccid'        => $topup->esim->iccid,
                    'topup_plan'   => $topup->name,
                    'price'        => showAmount($topup->price, currencyFormat: false),
                    'trx'          => $trnsaction->trx,
                    'post_balance' => showAmount($user->balance, currencyFormat: false),
                    'data_volume'  => dataVolume($topup->data_volume, isString: true),
                    'voice_quantity' => $topup->voice_quantity . ' minutes',
                    'sms_quantity'   => $topup->sms_quantity,
                    'validity'       => $topup->validity . ' days'
                ]);
            } else {
                $topup->status = Status::TOPUP_FAILED;
                $topup->failed_reason = $response['error'] ?? 'API error';
                $topup->save();

                return [
                    'status' => 'error',
                    'message' => $response['error'] ?? 'Topup failed'
                ];
            }
        } catch (\Exception $e) {
            $topup->status = Status::TOPUP_FAILED;
            $topup->failed_reason = $e->getMessage();
            $topup->save();

            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }

    private function resolveProvider($slug) {
        $provider = $this->providers->where('slug', $slug)->first();

        if (!$provider) {
            throw ValidationException::withMessages(['error' => "Provider '{$slug}' is not active"]);
        }

        return match ($slug) {
            'dataplansio'  => new DataPlans($provider),
            'esimsm'       => new EsimSM($provider),
            'esimaccess'   => new EsimAccess($provider),
            'esimcard'     => new EsimCard($provider),
            'airalo'       => new AirAlo($provider),
            default        => throw ValidationException::withMessages(['error' => "Unknown eSIM provider: {$slug}"]),
        };
    }
}
