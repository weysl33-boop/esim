<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::namespace('Api')->name('api.')->group(function () {
    Route::controller('AppController')->group(function () {
        Route::get('home', 'home');
        Route::get('get-countries', 'getCountries');
        Route::get('general-setting', 'generalSetting');
        Route::get('language/{key?}', 'getLanguage');
        Route::get('policies', 'policies');
        Route::get('policy/{slug}', 'policyContent');
        Route::get('faq', 'faq');
        Route::get('seo', 'seo');
        Route::get('get-extension/{act}', 'getExtension');
        Route::post('contact', 'submitContact');
        Route::get('cookie', 'cookie');
        Route::post('cookie/accept', 'cookieAccept');
        Route::get('custom-pages', 'customPages');
        Route::get('custom-page/{slug}', 'customPageData');
        Route::get('sections/{key?}', 'allSections');
        Route::get('ticket/{ticket}', 'viewTicket');
        Route::post('ticket/ticket-reply/{id}', 'replyTicket');
        Route::get('store-screen', 'storeScreen');

        // destinations
        Route::get('regions', 'regions');
        Route::get('countries', 'countries');
    });

    // Plan Controller
    Route::controller('PlanController')->group(function () {
        Route::get('campaign-plans/{id}', 'campaignPlans');
        Route::get('country-plans/{id}', 'countryPlans');
        Route::get('continental-plans/{id}', 'continentalPlans');
        Route::get('global-plans', 'globalPlans');
    });

    Route::namespace('Auth')->group(function () {
        Route::controller('LoginController')->group(function () {
            Route::post('login', 'login');
            Route::post('check-token', 'checkToken');
            Route::post('social-login', 'socialLogin');
        });

        Route::post('register', 'RegisterController@register');

        Route::controller('ForgotPasswordController')->group(function () {
            Route::post('password/email', 'sendResetCodeEmail');
            Route::post('password/verify-code', 'verifyCode');
            Route::post('password/reset', 'reset');
        });
    });

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('user-data-submit', 'UserController@userDataSubmit');

        //authorization
        Route::middleware('registration.complete')->controller('AuthorizationController')->group(function () {
            Route::get('authorization', 'authorization');
            Route::get('resend-verify/{type}', 'sendVerifyCode');
            Route::post('verify-email', 'emailVerification');
            Route::post('verify-mobile', 'mobileVerification');
            Route::post('verify-g2fa', 'g2faVerification');
        });

        Route::middleware(['check.status'])->group(function () {
            Route::middleware('registration.complete')->group(function () {
                Route::controller('UserController')->group(function () {
                    Route::get('download-attachments/{file_hash}', 'downloadAttachment')->name('download.attachment');
                    Route::post('profile-setting', 'submitProfile');
                    Route::post('change-password', 'submitPassword');
                    Route::get('user-info', 'userInfo');

                    //KYC
                    Route::get('kyc-form', 'kycForm');
                    Route::get('kyc-data', 'kycData');
                    Route::post('kyc-submit', 'kycSubmit');

                    //Report
                    Route::any('deposit/history', 'depositHistory');
                    Route::get('transactions', 'transactions');

                    Route::post('add-device-token', 'addDeviceToken');
                    Route::get('push-notifications', 'pushNotifications');
                    Route::post('push-notifications/read/{id}', 'pushNotificationsRead');

                    //2FA
                    Route::get('twofactor', 'show2faForm');
                    Route::post('twofactor/enable', 'create2fa');
                    Route::post('twofactor/disable', 'disable2fa');

                    // referral
                    Route::get('referrals', 'referrals');
                    Route::post('delete-account', 'deleteAccount');
                });

                // Plan purchase
                Route::controller('PlanController')->group(function () {
                    Route::post('plan/purchase', 'purchase');
                });

                Route::controller('OrderController')->group(function () {
                    Route::get('order/{scope}', 'orders')->whereIn('scope', ['pending', 'completed']);
                    Route::get('order/detail/{id}', 'detail');
                    Route::post('order/payment', 'payment');
                });

                // eSIM
                Route::controller('EsimController')->prefix('esim')->group(function () {
                    Route::get('{scope}', 'esims')->whereIn('scope', ['active', 'expired']);
                    Route::get('detail/{id}', 'detail');
                    Route::get('check-capacity/{id}', 'checkCapacity');
                    Route::post('cancel/{id}', 'cancel');
                });

                // eSIM topup
                Route::controller('TopupController')->prefix('esim')->group(function () {
                    Route::get('topups/{esimId?}', 'topupHistory');
                    Route::get('topup-plans/{id}', 'topupPlans');
                    Route::post('topup/{esimId}', 'topupSubmit');
                    Route::post('topup-payment/{topupId}', 'topupPayment');
                });

                // Payment
                Route::controller('PaymentController')->group(function () {
                    Route::get('deposit/methods', 'methods');
                    Route::post('deposit/insert', 'depositInsert');
                    Route::post('app/payment/confirm', 'appPaymentConfirm');
                    Route::post('manual/confirm', 'manualDepositConfirm');
                });

                Route::controller('TicketController')->prefix('ticket')->group(function () {
                    Route::get('/', 'supportTicket');
                    Route::post('create', 'storeSupportTicket');
                    Route::get('view/{ticket}', 'viewTicket');
                    Route::post('reply/{id}', 'replyTicket');
                    Route::post('close/{id}', 'closeTicket');
                    Route::get('download/{attachment_id}', 'ticketDownload');
                });
            });
        });

        Route::get('logout', 'Auth\LoginController@logout');
    });
});
