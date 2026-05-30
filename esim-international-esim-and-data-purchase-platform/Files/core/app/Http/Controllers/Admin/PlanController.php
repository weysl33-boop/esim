<?php

namespace App\Http\Controllers\Admin;

use App\Constants\Status;
use App\Http\Controllers\Controller;
use App\Models\Currency;
use App\Models\Plan;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PlanController extends Controller {

    public function plans() {
        return $this->getPlanData('All Plans');
    }

    public function detail($id) {
        $pageTitle = 'Plan Details';
        $plan      = Plan::with('countries', 'region', 'esimProvider')->findOrFail($id);
        return view('admin.plan.details', compact('pageTitle', 'plan'));
    }

    public function local() {
        return $this->getPlanData('Local Plans', 'local');
    }

    public function global() {
        return $this->getPlanData('Global Plans', 'global');
    }

    public function continental() {
        return $this->getPlanData('Continental Plans', 'continental');
    }

    private function getPlanData($pageTitle, $scope = null) {
        if ($scope) {
            $query = Plan::$scope();
        } else {
            $query = Plan::query();
        }

        $query = $query->with('region', 'currency', 'esimProvider')->filter(['status', 'package_type', 'region_id'])->searchable(['name']);

        if (request()->country) {
            $query = $query->whereHas('countries', function ($query) {
                $query->where('name', 'like', "%" . request()->country . "%");
            });
        }

        $plans = $query->orderBy('id', 'DESC')->paginate(getPaginate($this->getPageNumber()));

        $currencies = Currency::all();
        return view('admin.plan.index', compact('pageTitle', 'plans', 'currencies'));
    }

    private function getPageNumber() {
        $number = null;
        if (in_array(request()->per_page, [20, 50, 100, 150, 200])) {
            $number = request()->per_page;
        }

        return $number;
    }

    public function changeStatus(Request $request) {
        $flatPlans = implode(',', $request->plans);
        $plans     = explode(',', $flatPlans);
        $request->merge(['plans' => $plans]);

        $request->validate([
            'plans'  => 'required|array|min:1',
            'status' => ['required', Rule::in([Status::ENABLE, Status::DISABLE])],
        ]);

        $plans = Plan::whereIn('id', $request->plans)->update(
            ['status' => $request->status]
        );

        $notify[] = ['success', 'Status updated successfully'];
        return back()->withNotify($notify);
    }

    public function updateRetailPrice(Request $request, $id) {
        $plan = Plan::findOrFail($id);
        $request->validate([
            'retail_price' => 'required|numeric|min:0',
        ]);

        $plan->retail_price = $request->retail_price;
        $plan->save();

        $notify[] = ['success', 'Retail price updated successfully'];
        return back()->withNotify($notify);
    }
}
