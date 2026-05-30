class UrlContainer {
  static const String domainUrl = 'https://www.weairsim.com';

  static const String baseUrl = '$domainUrl/api/';

  static const String dashBoardEndPoint = 'home';
  static const String depositHistoryUrl = 'deposit/history';
  static const String depositMethodUrl = 'deposit/methods';
  static const String depositInsertUrl = 'deposit/insert';

  static const String registrationEndPoint = 'register';
  static const String loginEndPoint = 'login';
  static const String storeEndPoint = 'store-screen';
  static const String regionsEndPoint = 'regions';
  static const String countriesEndPoint = 'countries';
  static const String socialLoginEndPoint = 'social-login';

  static const String logoutUrl = 'logout';
  static const String forgetPasswordEndPoint = 'password/email';
  static const String passwordVerifyEndPoint = 'password/verify-code';
  static const String resetPasswordEndPoint = 'password/reset';
  static const String verify2FAUrl = 'verify-g2fa';

  static const String otpVerify = 'otp-verify';
  static const String otpResend = 'otp-resend';

  static const String verifyEmailEndPoint = 'verify-email';
  static const String verifySmsEndPoint = 'verify-mobile';
  static const String resendVerifyCodeEndPoint = 'resend-verify/';
  static const String authorizationCodeEndPoint = 'authorization';
  static const String referralsEndPoint = 'referrals';

  static const String transactionEndpoint = 'transactions';

  static const String addWithdrawRequestUrl = 'withdraw-request';
  static const String withdrawMethodUrl = 'withdraw-method';
  static const String withdrawRequestConfirm = 'withdraw-request/confirm';
  static const String withdrawHistoryUrl = 'withdraw/history';
  static const String withdrawStoreUrl = 'withdraw/store/';
  static const String withdrawConfirmScreenUrl = 'withdraw/preview/';

  static const String kycFormUrl = 'kyc-form';
  static const String kycSubmitUrl = 'kyc-submit';

  static const String generalSettingEndPoint = 'general-setting';
  //Notification
  static const String notificationListApi = "push-notifications";

  static const String privacyPolicyEndPoint = 'policies';
  static const String faqEndPoint = 'faq';

  static const String getProfileEndPoint = 'user-info';
  static const String updateProfileEndPoint = 'profile-setting';
  static const String profileCompleteEndPoint = 'user-data-submit';

  static const String changePasswordEndPoint = 'change-password';
  static const String countryEndPoint = 'get-countries';

  static const String deviceTokenEndPoint = 'add-device-token';
  static const String languageUrl = 'language/';
  static const String onBoardsApiEndPoint = 'onboarding';

  static const String twoFactor = "twofactor";
  static const String twoFactorEnable = "twofactor/enable";
  static const String twoFactorDisable = "twofactor/disable";

  //Wallet
  static const String walletEndPoint = "wallet";
  static const String walletListEndPoint = "wallet/list";
  static const String walletTransferToUserEndPoint = "wallet/transfer";
  static const String walletTransferToWalletEndPoint = "wallet/transfer/to/wallet";
  static const String pinValidate = "validate/password";

  //Pusher auth

  static const String pusherAuthApiURl = "pusher/auth";
  //Referrals
  static const String referURl = "$domainUrl?reference=";

//support ticket
  static const String supportMethodsEndPoint = 'support/method';
  static const String supportListEndPoint = 'ticket';
  static const String storeSupportEndPoint = 'ticket/create';
  static const String supportViewEndPoint = 'ticket/view';
  static const String supportReplyEndPoint = 'ticket/reply';
  static const String supportCloseEndPoint = 'ticket/close';
  static const String supportDownloadEndPoint = 'ticket/download';
  static const String accountDisable = 'delete-account';

  //payment methods
  static const String paymentMethods = 'p2p/payment-method';
  static const String createPaymentMethods = 'p2p/payment-method/create';
  static const String savePaymentMethods = 'p2p/payment-method/save';
  static const String editPaymentMethods = 'p2p/payment-method/edit';
  static const String deletePaymentMethods = 'p2p/payment-method/delete';

  //store details

  static const String storeDetails = 'country-plans/';
  static const String validCountries = 'countries';
  static const String globalPlan = 'global-plans/';
  static const String continentalPlan = 'continental-plans';
  static const String getPlanId = 'plan/purchase';
  static const String orderPayment = 'order/payment';
  static const String campaignPlansDetails = 'campaign-plans/';
  static const String userInfo = 'user-info';

  //myEsim
  static const String myActiveEsim = 'esim/active';
  static const String myExpiredEsim = 'esim/expired';
  static const String myActiveEsimData = 'esim/detail/';
  //topup
  static const String topUpPlans = 'esim/topup-plans/';
  static const String topUpPayment = 'esim/topup-payment/';
  static const String topUpPaymentInitiate = 'esim/topup/';

  //Url image
  static const String countryFlagImageLink = 'https://flagpedia.net/data/flags/h24/{countryCode}.webp';
  static const String withdraw = 'assets/images/verify/withdraw';
  static const String countryFlagAssetPath = '$domainUrl/assets/images/country/flag';
  static const String supportImagePath = '$domainUrl/assets/support/';
}
