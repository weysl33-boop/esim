<?php

namespace App\Http\Controllers\Admin;

use App\Constants\Status;
use App\Http\Controllers\Controller;
use App\Lib\RequiredConfig;
use App\Models\EsimProvider;
use App\Models\Region;
use App\Rules\FileTypeValidate;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class RegionController extends Controller {
    public function index() {
        $pageTitle = 'Regions';
        $regions   = Region::searchable(['name', 'slug'])->withCount('plans')->paginate(getPaginate());
        return view('admin.region.index', compact('pageTitle', 'regions'));
    }

    public function update($id, Request $request) {
        $request->validate([
            'region_image' => ['nullable', 'image', new FileTypeValidate(['jpg', 'jpeg', 'png'])],
            'banner' => ['nullable', 'image', new FileTypeValidate(['jpg', 'jpeg', 'png'])],
        ]);

        $region = Region::findOrFail($id);
        if ($request->hasFile('region_image')) {
            try {
                $image                = $request->file('region_image');
                $extension            = $image->getClientOriginalExtension();
                $filename             = $region->slug . '.' . $extension;
                $region->region_image = fileUploader($image, getFilePath('regionImage'), getFileSize('regionImage'), $region->region_image, filename: $filename);
            } catch (\Exception $e) {
                $notify[] = ['errors', 'Image could not be uploaded'];
                return back()->withNotify($notify);
            }
        }

        if ($request->hasFile('banner')) {
            try {
                $image           = $request->file('banner');
                $region->banner  = fileUploader($image, getFilePath('regionBanner'), getFileSize('regionBanner'), $region->banner);
            } catch (\Exception $e) {
                $notify[] = ['errors', 'Banner could not be uploaded'];
                return back()->withNotify($notify);
            }
        }

        $region->save();
        $notify[] = ['success', 'Region updated successfully'];
        return back()->withNotify($notify);
    }

    public function changeStatus($id) {
        return Region::changeStatus($id);
    }

    public function changeBulkStatus(Request $request) {
        $regions = explode(',', $request->regions);
        $request->merge(['regions' => $regions]);

        $request->validate([
            'regions' => 'required|array|min:1',
            'status'  => ['required', Rule::in([Status::ENABLE, Status::DISABLE])],
        ]);

        Region::whereIn('id', $request->regions)->update([
            'status' => $request->status
        ]);

        $notify[] = ['success', 'Status updated successfully'];
        return back()->withNotify($notify);
    }

    public function fetchRegions(Request $request) {
        $request->validate([
            'esim_provider_id' => 'required'
        ]);

        $esimProvider = EsimProvider::active()->findOrFail($request->esim_provider_id);

        try {
            $regions   = esimService()->fetchRegions($esimProvider->slug);
        } catch (\Exception $e) {
            $notify[] = ['error', 'API error: ' . $e->getMessage()];
            return back()->withNotify($notify);
        }
        $data = [];
        foreach ($regions as $item) {
            $region = Region::where('slug', $item['slug'])->orWhere('name', $item['name'])->first();
            if ($region) {
                $region->dataplansio_uid = $item['dataplansio_uid'] ?? $region->dataplansio_uid;
                $region->esimsm_uid = $item['esimsm_uid'] ?? $region->esimsm_uid;
                $region->esimaccess_uid = $item['esimaccess_uid'] ?? $region->esimaccess_uid;
                $region->esimcard_uid =  $item['esimcard_uid'] ?? $region->esimcard_uid;
                $region->airalo_uid =  $item['airalo_uid'] ?? $region->airalo_uid;
                $region->save();
            } else {
                $region = [
                    'name' => $item['name'],
                    'slug' => $item['slug'],
                    'dataplansio_uid' => $item['dataplansio_uid'] ?? null,
                    'esimsm_uid' => $item['esimsm_uid'] ?? null,
                    'esimaccess_uid' => $item['esimaccess_uid'] ?? null,
                    'esimcard_uid' => $item['esimcard_uid'] ?? null,
                    'airalo_uid' => $item['airalo_uid'] ?? null,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];

                $data[] = $region;
            }
        }

        if (count($data)) {
            Region::insert($data);
            RequiredConfig::configured('region');
        }

        $notify[] = ['success', 'Regions fetched successfully'];
        return back()->withNotify($notify);
    }
}
