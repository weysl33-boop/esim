<?php

namespace App\Http\Controllers;

use App\Lib\CurrencyLayer;
use Illuminate\Http\Request;
use App\Models\CronJob;
use App\Models\CronJobLog;
use App\Models\Currency;
use App\Traits\ManagePlan;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class CronController extends Controller {
    use ManagePlan;

    public function runManually(Request $request) {
        $alias = $request->alias;
        $result = $this->$alias();

        if (!$result['success']) {
            $notify[] = ['error', $result['error']];
            return back()->withNotify($notify);
        }

        $notify[] = ['success', 'Cron executed successfully'];
        return back()->withNotify($notify);
    }

    public function fetchCurrency() {

        $startTime = now();
        $error = null;
        $this->updateLastCronTime('fetchCurrency');

        try {
            $currencies = Currency::pluck('api_currency')->toArray();
            $currencyLayer = new CurrencyLayer();
            $currencyLayer->updateRates($currencies);
        } catch (\Exception $e) {
            Log::error('Currency fetch error: ' . $e->getMessage());
            $error = $e->getMessage();
        }

        $this->storeCronLog('fetchCurrency', $startTime, now(), $error);

        if ($error) {
            return ['success' => false, 'error' => $error];
        }
        return ['success' => true];
    }

    public function syncPlanFromDataPlans() {
        $startTime = now();
        $error = null;
        $this->updateLastCronTime('syncPlanFromDataPlans');

        try {
            $plans = esimService()->fetchPlans('dataplansio');
            $this->addOrUpdatePlans($plans);
        } catch (\Exception $e) {
            $error = $e->getMessage();
            Log::error('DataPlans.io sync error: ' . $error);
        }

        $this->storeCronLog('syncPlanFromDataPlans', $startTime, now(), $error);

        if ($error) {
            return ['success' => false, 'error' => $error];
        }
        return ['success' => true];
    }

    public function syncPlanFromEsimSM() {
        $startTime = now();
        $error = null;
        $this->updateLastCronTime('syncPlanFromEsimSM');

        try {
            $plans = esimService()->fetchPlans('esimsm');
            $this->addOrUpdatePlans($plans);
        } catch (\Exception $e) {
            $error = $e->getMessage();
            Log::error('EsimSM sync error: ' . $error);
        }

        $this->storeCronLog('syncPlanFromEsimSM', $startTime, now(), $error);

        if ($error) {
            return ['success' => false, 'error' => $error];
        }
        return ['success' => true];
    }

    public function syncPlanFromEsimAccess() {
        $startTime = now();
        $error = null;
        $this->updateLastCronTime('syncPlanFromEsimAccess');

        try {
            $plans = esimService()->fetchPlans('esimaccess');
            $this->addOrUpdatePlans($plans);
        } catch (\Exception $e) {
            $error = $e->getMessage();
            Log::error('EsimAccess sync error: ' . $error);
        }

        $this->storeCronLog('syncPlanFromEsimAccess', $startTime, now(), $error);

        if ($error) {
            return ['success' => false, 'error' => $error];
        }
        return ['success' => true];
    }

    public function syncPlanFromEsimCard() {
        $startTime = now();
        $error = null;
        $this->updateLastCronTime('syncPlanFromEsimCard');

        try {
            $plans = esimService()->fetchPlans('esimcard');
            $this->addOrUpdatePlans($plans);
        } catch (\Exception $e) {
            $error = $e->getMessage();
            Log::error('EsimAccess sync error: ' . $error);
        }

        $this->storeCronLog('syncPlanFromEsimCard', $startTime, now(), $error);

        if ($error) {
            return ['success' => false, 'error' => $error];
        }
        return ['success' => true];
    }

    public function syncPlanFromAiralo() {
        $startTime = now();
        $error = null;
        $this->updateLastCronTime('syncPlanFromAiralo');

        try {
            $plans = esimService()->fetchPlans('airalo');
            $this->addOrUpdatePlans($plans);
        } catch (\Exception $e) {
            $error = $e->getMessage();
            Log::error('EsimAccess sync error: ' . $error);
        }

        $this->storeCronLog('syncPlanFromAiralo', $startTime, now(), $error);

        if ($error) {
            return ['success' => false, 'error' => $error];
        }
        return ['success' => true];
    }

    private function updateLastCronTime($alias) {
        $cronJob = CronJob::where('alias', $alias)->first();
        $cronJob->last_run = now();
        $cronJob->save();
    }

    private function storeCronLog($alias, $startTime, $endTime, $error = '') {
        $cronJob = CronJob::where('alias', $alias)->first();

        if ($cronJob) {
            $cronJob->last_run = $endTime;
            $cronJob->save();

            // Cron job log data store
            $startTime         = Carbon::parse($startTime);
            $endTime           = Carbon::parse($endTime);
            $diffInSeconds     = $startTime->diffInSeconds($endTime);

            $cronLog              = new CronJobLog();
            $cronLog->cron_job_id = $cronJob->id;
            $cronLog->start_at    = $startTime;
            $cronLog->error       = $error;
            $cronLog->end_at      = $endTime;
            $cronLog->duration    = $diffInSeconds;
            $cronLog->save();
        }
    }
}
