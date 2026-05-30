<?php

namespace App\Http\Controllers\Admin;

use App\Constants\Status;
use App\Http\Controllers\Controller;
use App\Models\Campaign;
use App\Models\Country;
use App\Models\Plan;
use App\Models\Region;
use App\Rules\FileTypeValidate;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CampaignController extends Controller {
    public function index() {
        $pageTitle = 'All Campaigns';
        $campaigns = Campaign::orderBy('id', 'DESC')->withCount('plans')->paginate(getPaginate());
        return view('admin.campaign.index', compact('pageTitle', 'campaigns'));
    }

    public function create($id = 0) {
        $pageTitle = 'Create Campaign';
        $campaign = null;

        if ($id) {
            $campaign = Campaign::with('plans')->findOrFail($id);
            $pageTitle = 'Edit Campaign';
        }

        $countries = Country::active()->get();
        $regions   = Region::active()->get();

        return view('admin.campaign.create', compact('pageTitle', 'campaign', 'countries', 'regions'));
    }

    public function store(Request $request, $id = null) {
        $imgValidation = $id ? 'nullable' : 'required';

        $rules = [
            'title'    => 'required|string',
            'slug' => ['required', 'string', 'min:3', 'max:255', Rule::unique('campaigns', 'slug')->ignore($id)],
            'discount' => 'required|numeric|between:0,100',
            'banner'   => [$imgValidation, new FileTypeValidate(['jpg', 'jpeg', 'png'])],
            'seo_image' => ['nullable', new FileTypeValidate(['jpg', 'jpeg', 'png'])],
            'keywords' => 'nullable|array',
            'keywords.*' => 'nullable|string',
            'description' => 'nullable|string',
            'social_title' => 'nullable|string',
            'social_description' => 'nullable|string',
            'meta_robots' => 'nullable|string',
            'plans'    => 'required|array',
            'plans.*'  => ['required', Rule::exists('plans', 'id')->where('status', Status::ENABLE)],
        ];

        $request->validate($rules);

        if ($id) {
            $campaign = Campaign::findOrFail($id);
            $message  = 'Campaign updated successfully';
        } else {
            $campaign = new Campaign();
            $message  = 'Campaign created successfully';
        }

        $campaign->title = $request->title;
        $campaign->slug = slug($request->slug);
        $campaign->discount = $request->discount;

        if ($request->hasFile('banner')) {
            try {
                $old = $campaign->banner;
                $campaign->banner = fileUploader($request->file('banner'), getFilePath('campaign'), getFileSize('campaign'), $old);
            } catch (\Exception $e) {
                $notify[] = 'Could not upload the banner image';
                return back()->withNotify($notify)->withInput();
            }
        }

        $seoImage = data_get($campaign->seo_content, 'image');
        if ($request->hasFile('seo_image')) {
            try {
                $seoImage = fileUploader($request->file('seo_image'), getFilePath('seo'), getFileSize('seo'), $seoImage);
            } catch (\Exception $e) {
                $notify[] = 'Could not upload the SEO image';
                return back()->withNotify($notify)->withInput();
            }
        }

        $campaign->seo_content = [
            'keywords' => $request->keywords ?? [],
            'description' => $request->description,
            'social_title' => $request->social_title,
            'social_description' => $request->social_description,
            'meta_robots' => $request->meta_robots,
            'image' => $seoImage
        ];

        $campaign->save();
        $plans = $request->plans;
        Plan::whereIn('id', $plans)->update(['campaign_id' => $campaign->id]);

        $notify[] = ['success', $message];
        return back()->withNotify($notify);
    }

    public function checkSlug(Request $request, $id = null) {
        $slug = slug($request->slug ?? '');
        if (!$slug) {
            return response()->json(['exists' => false]);
        }

        $exists = Campaign::where('slug', $slug)
            ->when($id, fn($query) => $query->where('id', '!=', $id))
            ->exists();

        return response()->json([
            'exists' => $exists
        ]);
    }

    public function plans(Request $request) {
        $plans = Plan::active()->whereHas('esimProvider', function ($q) {
            $q->where('status', Status::YES);
        });

        if ($request->type == 'global') {
            $plans = $plans->global()->paginate();
        } elseif ($request->type == 'local' && $request->country_id) {
            $plans = $plans->whereHas('countries', function ($q) use ($request) {
                $q->where('country_id', $request->country_id);
            })->paginate();
        } elseif ($request->type == 'continental' && $request->region_id) {
            $plans = $plans->where('region_id', $request->region_id)->paginate();
        } else {
            $plans = collect();
        }

        return [
            'status' => 'success',
            'current_page' => $plans->count() > 0 ? $plans->currentPage() : 0,
            'pages' => $plans->count() > 0 ?  $plans->lastPage() : 0,
            'plans' => $plans
        ];
    }

    public function status($id) {
        return Campaign::changeStatus($id);
    }
}
