import 'package:get/get.dart';
import 'package:esim/data/model/store/store_details_data_response_model.dart';
import 'package:esim/view/screens/auth/authentication_screen.dart';
import 'package:esim/view/screens/auth/email_verification_page/email_verification_screen.dart';
import 'package:esim/view/screens/auth/forget_password/reset_password/reset_password_screen.dart';
import 'package:esim/view/screens/auth/forget_password/verify_forget_password/verify_forget_password_screen.dart';
import 'package:esim/view/screens/deposit/deposit_screen.dart';
import 'package:esim/view/screens/deposit/history/deposit_history_screen.dart';
import 'package:esim/view/screens/edit_profile/edit_profile_screen.dart';
import 'package:esim/view/screens/language/language_screen.dart';
import 'package:esim/view/screens/my_esim_details/my_esim_details_screen.dart';
import 'package:esim/view/screens/notification/notification_screen.dart';
import 'package:esim/view/screens/payment-method/add_payment_method_screen.dart';
import 'package:esim/view/screens/payment-method/edit_payment_method_screen.dart';
import 'package:esim/view/screens/payment-method/payment_method_screen.dart';
import 'package:esim/view/screens/preview_image/preview_image.dart';
import 'package:esim/view/screens/profile/profile_screen.dart';
import 'package:esim/view/screens/referral/referral_screen.dart';
import 'package:esim/view/screens/store_details/store_details_screen.dart';
import 'package:esim/view/screens/ticket/add_new_ticket_screen/add_new_ticket_screen.dart';
import 'package:esim/view/screens/ticket/all_support_ticket_screen.dart';
import 'package:esim/view/screens/ticket/support_ticket_details/support_ticket_details.dart';
import 'package:esim/view/screens/top_up/top_up_plans_screen.dart';
import 'package:esim/view/screens/welcome/welcome_screen.dart';
import '../../view/screens/auth/forget_password/forget_password/forget_password.dart';
import '../../view/screens/auth/kyc/kyc_screen.dart';
import '../../view/screens/auth/profile_complete/profile_complete_screen.dart';
import '../../view/screens/auth/sms_verification_page/sms_verification_screen.dart';
import '../../view/screens/auth/two_factor_screen/two_factor_setup_screen.dart';
import '../../view/screens/auth/two_factor_screen/two_factor_verification_screen.dart';
import '../../view/screens/change-password/change_password_screen.dart';
import '../../view/screens/dashboard/dashboard_screen.dart';
import '../../view/screens/dashboard/screen/profile_and_settings/screen/security_setup_screen.dart';
import '../../view/screens/dashboard/screen/wallet/screen/wallet_history/wallet_history_screen.dart';
import '../../view/screens/deposit/widgets/webview/deposit_webview_widget.dart';
import '../../view/screens/faq/faq_screen.dart';
import '../../view/screens/onboard/onboard_screen.dart';
import '../../view/screens/privacy_policy/privacy_policy_screen.dart';
import '../../view/screens/splash/splash_screen.dart';

class RouteHelper {
  static const String splashScreen = "/splash_screen";
  static const String onboardScreen = "/onboard_screen";
  static const String welcomeScreen = "/welcome_screen";
  //Auth
  static const String authenticationScreen = "/authentication_screen";
  //Auth END

  static const String forgotPasswordScreen = "/forgot_password_screen";
  static const String changePasswordScreen = "/change_password_screen";
  static const String resetPasswordScreen = "/reset_pass_screen";
  static const String profileCompleteScreen = "/profile_complete_screen";

  static const String emailVerificationScreen = "/verify_email_screen";
  static const String smsVerificationScreen = "/verify_sms_screen";
  static const String verifyPassCodeScreen = "/verify_pass_code_screen";
  static const String twoFactorScreen = "/two-factor-screen";
  static const String twoFactorSetupScreen = "/two-factor-setup-screen";
  static const String securitySetupScreen = "/security_setup_screen";
  static const String kycScreen = "/kyc_screen";

  static const String profileScreen = "/profile_screen";
  static const String editProfileScreen = "/edit_profile_screen";
  static const String notificationScreen = "/notification_screen";
  static const String privacyScreen = "/privacy-screen";

  static const String walletHistoryScreen = "/my_wallet_history_screen";
  //DASHBAORD
  static const String dashboardScreen = "/dashboard_screen";
  //trade view

  //Deposit
  static const String depositScreen = "/deposit_screen";
  static const String depositHistoryScreen = "/deposit_history_screen";
  static const String depositWebViewScreen = '/deposit_webView';

  // Referral
  static const String referralScreen = "/referral_screen";

  //Faq
  static const String faqScreenScreen = "/faq_screen";

//Support
  static const String allSupportTicketScreen = '/all_support_ticket_screen';
  static const String supportTicketDetailsScreen = '/support_ticket_details_screen';
  static const String addNewSupportTicketScreen = '/add_new_support_ticket_screen';
  static const String previewImageScreen = "/preview-image-screen";
  static const String languageScreen = "/language-screen";

  // paymentMethod
  static const String paymentMethodScreen = "/payment_method_screen";
  static const String addPaymentMethodScreen = "/add_payment_method_screen";
  static const String editPaymentMethodScreen = "/edit_payment_method_screen";

  //store details
  static const String storeDetailsScreen = "/store_details_screen";
  static const String myEsimDetailsScreen = "/my_esim_details_screen";
  static const String topUpScreen = "/top_up_screen";

  List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: onboardScreen, page: () => const OnBoardScreen()),
    GetPage(name: welcomeScreen, page: () => const WelcomeScreen()),

    //AUTH
    GetPage(name: authenticationScreen, page: () => AuthenticationScreen(isShowLoginTab: Get.arguments == null || Get.arguments == true ? true : false)),

    //AUTH END

    GetPage(name: profileCompleteScreen, page: () => const ProfileCompleteScreen()),
    //Reset

    GetPage(name: forgotPasswordScreen, page: () => const ForgetPasswordScreen()),
    GetPage(name: verifyPassCodeScreen, page: () => const VerifyForgetPassScreen()),
    GetPage(name: resetPasswordScreen, page: () => const ResetPasswordScreen()),

    //Verifications
    GetPage(name: emailVerificationScreen, page: () => const EmailVerificationScreen()),

    GetPage(name: smsVerificationScreen, page: () => const SmsVerificationScreen()),
    GetPage(name: twoFactorScreen, page: () => const TwoFactorVerificationScreen()),

    GetPage(name: twoFactorSetupScreen, page: () => const TwoFactorSetupScreen()),
    GetPage(name: securitySetupScreen, page: () => const SecuritySetupScreen()),
    GetPage(name: kycScreen, page: () => const KycScreen()),

    //Profile
    GetPage(name: profileScreen, page: () => const ProfileScreen()),
    GetPage(name: editProfileScreen, page: () => const EditProfileScreen()),
    GetPage(name: changePasswordScreen, page: () => const ChangePasswordScreen()),
    GetPage(name: privacyScreen, page: () => const PrivacyPolicyScreen()),

    // dashboard
    GetPage(name: dashboardScreen, page: () => DashboardScreen()),

    GetPage(name: walletHistoryScreen, page: () => WalletHistoryScreen(remarkType: "${Get.arguments == null || Get.arguments == "" ? "" : Get.arguments}")),
    //Deposit
    GetPage(
        name: depositScreen,
        page: () => DepositScreen(
              planData: (Get.arguments[0] as List<PlanData>?) ?? [],
              planId: Get.arguments[1]?.toString() ?? "",
              price: Get.arguments[2]?.toString() ?? "",
              uid: Get.arguments[3]?.toString() ?? "",
            )),

    GetPage(name: depositHistoryScreen, page: () => const DepositHistoryScreen()),
    // In GetPage:
    GetPage(
        name: depositWebViewScreen,
        page: () => DepositWebviewWidget(
              redirectUrl: Get.arguments[0],
              planId: Get.arguments[1],
            )),
    GetPage(name: notificationScreen, page: () => const NotificationScreen()),

    //Referral
    GetPage(name: referralScreen, page: () => const ReferralScreen()),

    //Faq
    GetPage(name: faqScreenScreen, page: () => const FaqScreen()),

    //Supports
    GetPage(name: allSupportTicketScreen, page: () => const AllSupportTicketListScreen()),
    GetPage(name: supportTicketDetailsScreen, page: () => const SupportTicketDetailsScreen()),
    GetPage(name: addNewSupportTicketScreen, page: () => const AddNewSupportTicketScreen()),
    GetPage(name: previewImageScreen, page: () => PreviewImage(url: Get.arguments)),
    GetPage(name: languageScreen, page: () => const LanguageScreen()),

    //payment methods
    GetPage(name: paymentMethodScreen, page: () => const PaymentMethodScreen()),
    GetPage(name: addPaymentMethodScreen, page: () => const AddPaymentMethodScreen()),
    GetPage(name: editPaymentMethodScreen, page: () => const EditPaymentMethodScreen()),

    //store details
    GetPage(name: storeDetailsScreen, page: () => const StoreDetailsScreen()),
    GetPage(name: myEsimDetailsScreen, page: () => const MyEsimDetailsScreen()),
    GetPage(name: topUpScreen, page: () => const TopUpPlansScreen()),
  ];
}
