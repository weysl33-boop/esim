<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Lib\RequiredConfig;
use App\Models\EsimProvider;
use Illuminate\Http\Request;

class EsimProviderController extends Controller {
    public function all() {
        $pageTitle      = 'All eSIM Providers';
        $esimProviders   = EsimProvider::get();
        return view('admin.esim.providers', compact('pageTitle', 'esimProviders'));
    }

    public function update(Request $request, $id) {
        $request->validate([
            'currency' => 'required|string',
            'credentials' => 'required|array',
            'credentials.*' => 'required|string',
        ]);

        $esimProvider = EsimProvider::findOrFail($id);
        $esimProvider->currency = $request->currency;
        $esimProvider->credentials = $request->credentials;
        $esimProvider->save();

        RequiredConfig::configured('esim_provider');

        $notify[] = ['success', $esimProvider->provider. ' updated successfully'];
        return back()->withNotify($notify);
    }

    public function status($id) {
        return EsimProvider::changeStatus($id);
    }
}
