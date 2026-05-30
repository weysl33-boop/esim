<?php

use Illuminate\Support\Facades\Route;

Route::get('/clear', function () {
    \Illuminate\Support\Facades\Artisan::call('optimize:clear');
});

Route::controller('CronController')->prefix('cron')->name('cron.')->group(function () {
    Route::get('fetch-currency', 'fetchCurrency')->name('fetch.currency');
    Route::get('dataplansio/sync-plans', 'syncPlanFromDataPlans')->name('sync.dataplansio');
    Route::get('esimsm/sync-plans', 'syncPlanFromEsimSM')->name('sync.esimsm');
    Route::get('esimaccess/sync-plans', 'syncPlanFromEsimAccess')->name('sync.esimaccess');
    Route::get('esimcard/sync-plans', 'syncPlanFromEsimCard')->name('sync.esimcard');
    Route::get('airalo/sync-plans', 'syncPlanFromAiralo')->name('sync.airalo');
    Route::get('run-manually/{alias}', 'runManually')->name('manual.run');
});

Route::controller('WebhookController')->prefix('webhook')->group(function () {
    Route::any('esimaccess', 'esimaccess')->name('webhook.esimaccess');
});

// User Support Ticket
Route::controller('TicketController')->prefix('ticket')->name('ticket.')->group(function () {
    Route::get('/', 'supportTicket')->name('index');
    Route::get('new', 'openSupportTicket')->name('open');
    Route::post('create', 'storeSupportTicket')->name('store');
    Route::get('view/{ticket}', 'viewTicket')->name('view');
    Route::post('reply/{id}', 'replyTicket')->name('reply');
    Route::post('close/{id}', 'closeTicket')->name('close');
    Route::get('download/{attachment_id}', 'ticketDownload')->name('download');
});

Route::get('app/deposit/confirm/{hash}', 'Gateway\PaymentController@appDepositConfirm')->name('deposit.app.confirm');

Route::controller('SiteController')->group(function () {
    Route::get('contact', 'contact')->name('contact');
    Route::post('contact', 'contactSubmit');
    Route::get('change/{lang?}', 'changeLanguage')->name('lang');
    Route::get('cookie-policy', 'cookiePolicy')->name('cookie.policy');
    Route::post('send-message', 'sendMessage')->name('send.message');
    Route::get('cookie/accept', 'cookieAccept')->name('cookie.accept');
    Route::get('blogs', 'blogs')->name('blogs');
    Route::get('blog/{slug}', 'blogDetails')->name('blog.details');
    Route::get('global-plans', 'globalPlans')->name('global.plans');
    Route::get('country-plans/{slug}', 'countryPlans')->name('country.plans');
    Route::get('region-plans/{slug}', 'regionPlans')->name('region.plans');
    Route::get('all-countries', 'getAllCountries')->name('all.countries');
    Route::get('search/country', 'searchCountry')->name('search.country');
    Route::get('destination', 'destination')->name('destination');

    // campaign
    Route::get('campaign/{slug}', 'campaignDetails')->name('campaign.details');

    Route::get('policy/{slug}', 'policyPages')->name('policy.pages');

    Route::get('placeholder-image/{size}', 'placeholderImage')->withoutMiddleware('maintenance')->name('placeholder.image');
    Route::get('maintenance-mode', 'maintenance')->withoutMiddleware('maintenance')->name('maintenance');

    Route::get('/{slug}', 'pages')->name('pages');
    Route::get('/', 'index')->name('home');
});
