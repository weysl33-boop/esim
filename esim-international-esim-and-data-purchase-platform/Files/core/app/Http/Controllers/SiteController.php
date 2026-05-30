<?php

namespace App\Http\Controllers;

use App\Constants\Status;
use App\Models\AdminNotification;
use App\Models\Campaign;
use App\Models\Country;
use App\Models\Frontend;
use App\Models\Language;
use App\Models\Page;
use App\Models\Plan;
use App\Models\Region;
use App\Models\SupportMessage;
use App\Models\SupportTicket;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cookie;

class SiteController extends Controller {
    public function index() {
        if (isset($_GET['reference'])) {
            session()->put('reference', $_GET['reference']);
        }

        $pageTitle     = 'Home';
        $sections      = Page::where('tempname', activeTemplate())->where('slug', '/')->first();
        $seoContents   = $sections->seo_content;
        $seoImage      = isset($seoContents->image) ? getImage(getFilePath('seo') . '/' . $seoContents->image, getFileSize('seo')) : null;
        return view('Template::home', compact('pageTitle', 'sections', 'seoContents', 'seoImage'));
    }

    public function destination() {
        $pageTitle = 'Destination';
        $sections  = Page::where('tempname', activeTemplate())->where('slug', 'destination')->first();

        $countries = Country::active()
            ->whereHas('plans', function ($query) {
                $query->active()->whereHas('esimProvider', fn($provider) => $provider->active());
            })
            ->with([
                'plans' => function ($plan) {
                    $plan->active()->whereHas('esimProvider', fn($provider) => $provider->active());
                },
            ])
            ->featured()
            ->orderBy('name', 'ASC')
            ->get()
            ->map(function ($country) {
                $plan = $country->plans->sortBy('converted_price')->first();
                $country->converted_price = $plan->converted_price;
                return $country;
            })
            ->toArray();

        $regions = Region::active()
            ->whereNotIn('slug', ['local', 'global'])
            ->withCount([
                'plans' => function ($plan) {
                    $plan->active()->whereHas('esimProvider', fn($provider) => $provider->active());
                },
            ])
            ->having('plans_count', '>', 0)
            ->orderBy('name', 'ASC')
            ->get();

        $globalPlanCount = Plan::active()->global()->whereHas('esimProvider', fn($provider) => $provider->active())->count();
        return view('Template::destination', compact('pageTitle', 'countries', 'sections', 'regions', 'globalPlanCount'));
    }

    public function globalPlans() {
        $pageTitle = 'Global eSIM Plans';
        $plans = Plan::active()->global()->whereHas('esimProvider', function ($provider) {
            $provider->active();
        })->with('countries')->get();

        $plans = $this->convertPlanPrice($plans);
        $plans =  $plans->sortBy('converted_price');
        $title = 'Global eSIM';
        $flag = getImage('assets/images/globe.png');
        return view('Template::plans', compact('pageTitle', 'plans', 'title', 'flag', 'plans'));
    }

    public function countryPlans($slug) {
        $country = Country::with(['plans' => function ($query) {
            $query->active()->whereHas('esimProvider', function ($provider) {
                $provider->active();
            })->with('countries');
        }])->active()->where('slug', $slug)->firstOrFail();

        $pageTitle = $country->name . ' eSIM Plans';
        $plans = $country->plans->sortBy('converted_price');

        $title = $country->name . '\'s eSIM';
        $flag = $country->image ? getImage(getFilePath('countryFlag') . '/' . $country->image, getFileSize('countryFlag')) : null;
        $flagCode = $country->code;
        return view('Template::plans', compact('pageTitle', 'country', 'plans', 'title', 'flag', 'flagCode'));
    }

    public function regionPlans($slug) {
        $region = Region::active()->with(['plans' => function ($query) {
            $query->active()
                ->whereHas('countries', fn($q) => $q->active())
                ->whereHas('esimProvider', fn($provider) => $provider->active())
                ->with('currency', 'countries');
        }])->active()->where('slug', $slug)->firstOrFail();

        $pageTitle = $region->name . ' eSIM Plans';

        $plans = $this->convertPlanPrice($region->plans);
        $plans  = $plans->sortBy('converted_price');

        $title = $region->name . '\'s eSIM';
        $flag = $region->image ? getImage(getFilePath('regionImage') . '/' . $region->image, getFileSize('regionImage')) : null;
        return view('Template::plans', compact('pageTitle', 'region', 'plans', 'title', 'flag'));
    }

    public function campaignDetails($slug) {
        $campaign = Campaign::active()
            ->where('slug', $slug)
            ->firstOrFail();

        $plans = Plan::active()
            ->where('campaign_id', $campaign->id)
            ->whereHas('esimProvider', fn($provider) => $provider->active())
            ->with('countries', 'campaign')
            ->get()
            ->sortBy('converted_price');

        $pageTitle   = $campaign->title . ' Offers';
        $title       = $campaign->title;
        $subtitle    = $campaign->discount . '% off on selected plans';
        $banner      = getImage(getFilePath('campaign') . '/' . $campaign->banner, getFileSize('campaign'));
        $seoContents = $campaign->seo_content;
        $seoImage    = isset($seoContents->image) && $seoContents->image ? getImage(getFilePath('seo') . '/' . $seoContents->image, getFileSize('seo')) : $banner;

        return view('Template::plans', compact('campaign', 'plans', 'pageTitle', 'title', 'subtitle', 'banner', 'seoContents', 'seoImage'));
    }

    private function convertPlanPrice($plans) {
        $baseCurrency = gs('cur_text');

        return $plans->map(function ($plan) use ($baseCurrency) {
            $convertedPrice = $plan->retail_price;

            if ($plan->currency && $plan->currency->conversion_rate > 0) {
                if ($plan->currency->api_currency !== $baseCurrency) {
                    $convertedPrice = $plan->retail_price / $plan->currency->conversion_rate;
                }
            }

            $plan->converted_price = $convertedPrice;
            return $plan;
        });
    }

    public function searchCountry(Request $request) {
        $keyword = strtolower($request->keyword);

        $countries = Country::active()->whereHas('plans', function ($query) {
            $query->active()->whereHas('esimProvider', fn($provider) => $provider->active());
        })->where(function ($query) use ($keyword) {
            $query->where('name', 'like', "%{$keyword}%")
                ->orWhere('code', 'like', "%{$keyword}%");
        })->with('plans.region')->get();

        $html = view('Template::partials.country_result', ['countries' => $countries])->render();
        return response()->json(['html' => $html]);
    }

    public function pages($slug) {
        $page        = Page::where('tempname', activeTemplate())->where('slug', $slug)->firstOrFail();
        $pageTitle   = $page->name;
        $sections    = $page->secs;
        $seoContents = $page->seo_content;
        $seoImage    = isset($seoContents->image) ? getImage(getFilePath('seo') . '/' . $seoContents->image, getFileSize('seo')) : null;
        return view('Template::pages', compact('pageTitle', 'sections', 'seoContents', 'seoImage'));
    }

    public function contact() {
        $pageTitle   = "Contact Us";
        $user        = auth()->user();
        $sections    = Page::where('tempname', activeTemplate())->where('slug', 'contact')->first();
        $seoContents = $sections->seo_content;
        $seoImage    = isset($seoContents->image) ? getImage(getFilePath('seo') . '/' . $seoContents->image, getFileSize('seo')) : null;
        return view('Template::contact', compact('pageTitle', 'user', 'sections', 'seoContents', 'seoImage'));
    }

    public function contactSubmit(Request $request) {
        $request->validate([
            'name'    => 'required',
            'email'   => 'required',
            'subject' => 'required|string|max:255',
            'message' => 'required',
        ]);

        $request->session()->regenerateToken();

        if (!verifyCaptcha()) {
            $notify[] = ['error', 'Invalid captcha provided'];
            return back()->withNotify($notify);
        }

        $random = getNumber();

        $ticket           = new SupportTicket();
        $ticket->user_id  = auth()->id() ?? 0;
        $ticket->name     = $request->name;
        $ticket->email    = $request->email;
        $ticket->priority = Status::PRIORITY_MEDIUM;

        $ticket->ticket     = $random;
        $ticket->subject    = $request->subject;
        $ticket->last_reply = Carbon::now();
        $ticket->status     = Status::TICKET_OPEN;
        $ticket->save();

        $adminNotification            = new AdminNotification();
        $adminNotification->user_id   = auth()->user() ? auth()->user()->id : 0;
        $adminNotification->title     = 'A new contact message has been submitted';
        $adminNotification->click_url = urlPath('admin.ticket.view', $ticket->id);
        $adminNotification->save();

        $message                    = new SupportMessage();
        $message->support_ticket_id = $ticket->id;
        $message->message           = $request->message;
        $message->save();

        $notify[] = ['success', 'Ticket created successfully!'];

        return to_route('ticket.view', [$ticket->ticket])->withNotify($notify);
    }

    public function policyPages($slug) {
        $policy = Frontend::where('tempname', activeTemplateName())->where('slug', $slug)->where('data_keys', 'policy_pages.element')->firstOrFail();
        $pageTitle   = $policy->data_values->title;
        $seoContents = $policy->seo_content;
        $seoImage    = isset($seoContents->image) ? frontendImage('policy_pages', $seoContents->image, getFileSize('seo'), true) : null;
        return view('Template::policy', compact('policy', 'pageTitle', 'seoContents', 'seoImage'));
    }

    public function changeLanguage($lang = null) {
        $language = Language::where('code', $lang)->first();
        if (!$language) {
            $lang = 'en';
        }

        session()->put('lang', $lang);
        return back();
    }

    public function blogs() {
        $pageTitle   = 'Blogs';
        $blogs       = Frontend::where('data_keys', 'blog.element')->latest()->paginate(getPaginate(9));
        $sections    = Page::where('tempname', activeTemplate())->where('slug', 'blog')->first();
        $seoContents = $sections->seo_content;
        $seoImage    = isset($seoContents->image) ? frontendImage('blog', $seoContents->image, getFileSize('seo'), true) : null;
        return view('Template::blogs', compact('pageTitle', 'blogs', 'sections', 'seoContents', 'seoImage'));
    }

    public function blogDetails($slug) {
        $blog        = Frontend::where('slug', $slug)->where('data_keys', 'blog.element')->firstOrFail();
        $latest      = Frontend::where('data_keys', 'blog.element')->where('id', '!=', $blog->id)->orderBy('id', 'DESC')->limit(5)->get();
        $pageTitle   = 'Blog Details';
        $seoContents = $blog->seo_content;
        $seoImage    = isset($seoContents->image) ? frontendImage('blog', $seoContents->image, getFileSize('seo'), true) : null;
        return view('Template::blog_details', compact('blog', 'pageTitle', 'seoContents', 'seoImage', 'latest'));
    }

    public function cookieAccept() {
        Cookie::queue('gdpr_cookie', gs('site_name'), 43200);
    }

    public function cookiePolicy() {
        $cookieContent = Frontend::where('data_keys', 'cookie.data')->first();
        abort_if($cookieContent->data_values->status != Status::ENABLE, 404);
        $pageTitle = 'Cookie Policy';
        $cookie    = Frontend::where('data_keys', 'cookie.data')->first();
        return view('Template::cookie', compact('pageTitle', 'cookie'));
    }

    public function placeholderImage($size = null) {
        $imgWidth  = explode('x', $size)[0];
        $imgHeight = explode('x', $size)[1];
        $text      = $imgWidth . '×' . $imgHeight;
        $fontFile  = realpath('assets/font/solaimanLipi_bold.ttf');
        $fontSize  = round(($imgWidth - 50) / 8);
        if ($fontSize <= 9) {
            $fontSize = 9;
        }
        if ($imgHeight < 100 && $fontSize > 30) {
            $fontSize = 30;
        }

        $image     = imagecreatetruecolor($imgWidth, $imgHeight);
        $colorFill = imagecolorallocate($image, 100, 100, 100);
        $bgFill    = imagecolorallocate($image, 255, 255, 255);
        imagefill($image, 0, 0, $bgFill);
        $textBox    = imagettfbbox($fontSize, 0, $fontFile, $text);
        $textWidth  = abs($textBox[4] - $textBox[0]);
        $textHeight = abs($textBox[5] - $textBox[1]);
        $textX      = ($imgWidth - $textWidth) / 2;
        $textY      = ($imgHeight + $textHeight) / 2;
        header('Content-Type: image/jpeg');
        imagettftext($image, $fontSize, 0, $textX, $textY, $colorFill, $fontFile, $text);
        imagejpeg($image);
        imagedestroy($image);
    }

    public function maintenance() {
        $pageTitle = 'Maintenance Mode';
        if (gs('maintenance_mode') == Status::DISABLE) {
            return to_route('home');
        }
        $maintenance = Frontend::where('data_keys', 'maintenance.data')->first();
        return view('Template::maintenance', compact('pageTitle', 'maintenance'));
    }
}
