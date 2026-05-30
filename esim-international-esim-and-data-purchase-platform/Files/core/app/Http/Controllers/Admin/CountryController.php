<?php

namespace App\Http\Controllers\Admin;

use App\Constants\Status;
use App\Http\Controllers\Controller;
use App\Lib\RequiredConfig;
use App\Models\Country;
use App\Models\EsimProvider;
use App\Rules\FileTypeValidate;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CountryController extends Controller {

    public function index() {
        $pageTitle = 'Countries';

        $number = null;
        if (in_array(request()->per_page, [20, 50, 100, 150, 200, 250])) {
            $number = request()->per_page;
        }

        $countries = Country::filter(['status', 'is_featured'])->searchable(['name', 'code'])->withCount('plans')->orderBy('name')->paginate(getPaginate($number));
        return view('admin.country.index', compact('pageTitle', 'countries'));
    }

    public function update($id, Request $request) {
        $request->validate([
            'image' => ['nullable', 'image', new FileTypeValidate(['jpg', 'jpeg', 'png'])],
            'banner' => ['nullable', 'image', new FileTypeValidate(['jpg', 'jpeg', 'png'])],
        ]);

        $country = Country::findOrFail($id);
        if ($request->hasFile('image')) {
            try {
                $image                  = $request->file('image');
                $extension              = $image->getClientOriginalExtension();
                $filename               = $country->code . '.' . $extension;
                $country->image         = fileUploader($image, getFilePath('countryFlag'), getFileSize('countryFlag'), $country->image, filename: $filename);
            } catch (\Exception $exp) {
                $notify[] = ['error', 'Image could not be uploaded'];
                return back()->withNotify($notify);
            }
        }

        if ($request->hasFile('banner')) {
            try {
                $image                  = $request->file('banner');
                $country->banner        = fileUploader($image, getFilePath('countryBanner'), getFileSize('countryBanner'), $country->banner);
            } catch (\Exception $exp) {
                $notify[] = ['error', 'Banner could not be uploaded'];
                return back()->withNotify($notify);
            }
        }

        $country->save();
        $notify[] = ['success', 'Country updated successfully'];
        return back()->withNotify($notify);
    }

    public function toggleFeature($id) {
        return Country::changeStatus($id, 'is_featured');
    }

    public function changeStatus(Request $request) {
        $countries = explode(',', $request->countries);
        $request->merge(['countries' => $countries]);

        $request->validate([
            'countries' => 'required|array|min:1',
            'status'    => ['required', Rule::in([Status::ENABLE, Status::DISABLE])],
        ]);

        $countries = Country::whereIn('id', $request->countries)->update(
            ['status' => $request->status]
        );

        $notify[] = ['success', 'Status updated successfully'];
        return to_route('admin.destination.country.index')->withNotify($notify);
    }

    public function fetchCountries(Request $request) {
        $request->validate([
            'esim_provider_id' => 'required'
        ]);

        $esimProvider = EsimProvider::active()->findOrFail($request->esim_provider_id);

        try {
            $countries = esimService()->fetchCountries($esimProvider->slug);
        } catch (\Exception $e) {
            $notify[] = ['error', 'API error: ' . $e->getMessage()];
            return  back()->withNotify($notify);
        }

        $data = [];
        foreach ($countries as $item) {
            $country = Country::where('code', $item['code'])->orWhere('name', $item['name'])->first();
            if ($country) {
                $country->dataplansio_uid = $item['dataplansio_uid'] ?? $country->dataplansio_uid;
                $country->esimsm_uid = $item['esimsm_uid'] ?? $country->esimsm_uid;
                $country->esimaccess_uid = $item['esimaccess_uid'] ?? $country->esimaccess_uid;
                $country->esimcard_uid = $item['esimcard_uid'] ?? $country->esimcard_uid;
                $country->airalo_uid = $item['airalo_uid'] ?? $country->airalo_uid;
                $country->save();
            } else {
                $countryItem = [
                    'code' => $item['code'],
                    'name' => $item['name'],
                    'slug' => str()->slug($item['name']),
                    'dataplansio_uid' => $item['dataplansio_uid'] ?? null,
                    'esimsm_uid' => $item['esimsm_uid'] ?? null,
                    'esimaccess_uid' => $item['esimaccess_uid'] ?? null,
                    'esimcard_uid' => $item['esimcard_uid'] ?? null,
                    'airalo_uid' => $item['airalo_uid'] ?? null,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];

                $data[] = $countryItem;
            }
        }

        if (count($data)) {
            Country::insert($data);
            RequiredConfig::configured('country');
        }

        $notify[] = ['success', 'Countries fetched successfully'];
        return back()->withNotify($notify);
    }
}
