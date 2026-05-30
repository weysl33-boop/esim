import 'dart:async';
import 'dart:convert';
import 'package:esim/data/model/general_setting/general_setting_response_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:esim/core/helper/shared_preference_helper.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/route/route.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/data/model/auth/login/login_response_model.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/repo/auth/login_repo.dart';
import 'package:esim/view/components/app-bar/app_main_appbar.dart';
import 'package:esim/view/components/snack_bar/show_custom_snackbar.dart';

import '../../../../core/packages/signin_with_linkdin/signin_with_linkedin.dart';

class LoginController extends GetxController {
  LoginRepo loginRepo;
  LoginController({required this.loginRepo});

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  String? email;
  String? password;

  List<String> errors = [];
  bool remember = true;

  void forgetPassword() {
    Get.toNamed(RouteHelper.forgotPasswordScreen);
  }

  void checkAndGotoNextStep(LoginResponseModel responseModel, {bool fromSocialLogin = false}) async {
    bool needEmailVerification = responseModel.data?.user?.ev == "1" ? false : true;
    bool needSmsVerification = responseModel.data?.user?.sv == '1' ? false : true;
    bool isTwoFactorEnable = responseModel.data?.user?.tv == '1' ? false : true;

    await loginRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, true); // always will be true

    await loginRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userIdKey, responseModel.data?.user?.id.toString() ?? '-1');
    await loginRepo.apiClient.storeAuthTokenData(
      accessToken: responseModel.data?.accessToken ?? '',
      accessType: responseModel.data?.tokenType ?? '',
    );
    await loginRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userEmailKey, responseModel.data?.user?.email ?? '');
    await loginRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userPhoneNumberKey, responseModel.data?.user?.mobile ?? '');
    await loginRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userNameKey, responseModel.data?.user?.username ?? '');

    unawaited(loginRepo.sendUserToken());

    bool isProfileCompleteEnable = responseModel.data?.user?.profileComplete == '0' ? true : false;
    if (needSmsVerification == false && needEmailVerification == false && isTwoFactorEnable == false) {
      if (isProfileCompleteEnable) {
        Get.offAndToNamed(RouteHelper.profileCompleteScreen);
      } else {
        await loginRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.firstTimeOnAppKey, false);
        clearTextField();
        Get.offAndToNamed(RouteHelper.dashboardScreen);
      }
    } else if (needSmsVerification == true && needEmailVerification == true && isTwoFactorEnable == true) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen, arguments: [true, isProfileCompleteEnable, isTwoFactorEnable]);
    } else if (needSmsVerification == true && needEmailVerification == true) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen, arguments: [true, isProfileCompleteEnable, isTwoFactorEnable]);
    } else if (needSmsVerification) {
      Get.offAndToNamed(RouteHelper.smsVerificationScreen, arguments: [isProfileCompleteEnable, isTwoFactorEnable]);
    } else if (needEmailVerification) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen, arguments: [false, isProfileCompleteEnable, isTwoFactorEnable]);
    } else if (isTwoFactorEnable) {
      Get.offAndToNamed(RouteHelper.twoFactorScreen, arguments: isProfileCompleteEnable);
    }
  }

  bool isSubmitLoading = false;
  void loginUser() async {
    isSubmitLoading = true;
    update();

    ResponseModel model = await loginRepo.loginUser(emailController.text.toString(), passwordController.text.toString());

    if (model.statusCode == 200) {
      LoginResponseModel loginModel = LoginResponseModel.fromJson(jsonDecode(model.responseJson));
      if (loginModel.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
        checkAndGotoNextStep(loginModel);
      } else {
        CustomSnackBar.error(errorList: loginModel.message?.error ?? [MyStrings.loginFailedTryAgain]);
      }
    } else {
      CustomSnackBar.error(errorList: [model.message]);
    }

    isSubmitLoading = false;
    update();
  }

  void clearTextField() {
    passwordController.text = '';
    emailController.text = '';

    update();
  }

  //SIGN IN With Google
  bool isSocialSubmitLoading = false;
  bool isGoogle = false;
  bool isFacebook = false;
  bool isLinkedin = false;

  Future<void> signInWithGoogle() async {
    try {
      isLinkedin = false;
      isGoogle = true;
      update();
      const List<String> scopes = <String>['email', 'profile'];
      googleSignIn.signOut();

      await googleSignIn.initialize();
      var googleUser = await googleSignIn.attemptLightweightAuthentication();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        if (googleAuth.idToken == null) {
          // throw Exception('Google Sign-In canceled by user');
          isGoogle = false;
          update();
          return;
        }
        final GoogleSignInClientAuthorization? authorization = await googleUser.authorizationClient.authorizationForScopes(scopes);
        printX(authorization?.accessToken);

        await socialLoginUser(
          provider: 'google',
          accessToken: authorization?.accessToken ?? '',
        );
      }
    } catch (e) {
      printX(e.toString());

      // CustomSnackBar.error(errorList: [e.toString()]);
    } finally {
      isGoogle = false;
      update();
    }
  }

  //SIGN IN With LinkeDin

  Future<void> signInWithLinkeDin(BuildContext context) async {
    try {
      isLinkedin = true;
      update();

      SocialiteCredentials linkedinCredential = loginRepo.apiClient.getSocialCredentialsConfigData();
      String linkedinCredentialRedirectUrl = "${loginRepo.apiClient.getSocialCredentialsRedirectUrl()}/linkedin";
      late final linkedin = SignInWithLinkedIn(
        config: LinkedInConfig(
          clientId: linkedinCredential.linkedin?.clientId ?? '',
          clientSecret: linkedinCredential.linkedin?.clientSecret ?? '',
          scope: ['openid', 'profile', 'email'],
          redirectUrl: linkedinCredentialRedirectUrl,
        ),
      );

      final (
        authCode,
        error,
      ) = await linkedin.getAuthorizationCode(
        context: context,
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          title: MyStrings.signInWithLinkedIn.tr,
          bgColor: MyColor.transparentColor,
          titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
          leadingWidgetOnTap: () {
            Get.back();
          },
          actions: [],
        ),
      );
      if (authCode != null) {
        final (tokenInfo, error) = await linkedin.getAccessToken(
          authorizationCode: authCode,
        );

        if (tokenInfo != null) {
          await socialLoginUser(provider: 'linkedin', accessToken: tokenInfo.accessToken);
        } else {
          printX('Error on sign in: $error');
        }
      }
    } catch (e) {
      printX(e.toString());

      CustomSnackBar.error(errorList: [e.toString()]);
    } finally {
      isLinkedin = false;
      update();
    }
  }

  //Social Login API PART

  Future socialLoginUser({
    String accessToken = '',
    String? provider,
  }) async {
    isSocialSubmitLoading = true;

    update();

    try {
      ResponseModel responseModel = await loginRepo.socialLoginUser(
        accessToken: accessToken,
        provider: provider,
      );
      if (responseModel.statusCode == 200) {
        LoginResponseModel loginModel = LoginResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (loginModel.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
          remember = true;
          update();
          checkAndGotoNextStep(loginModel);
        } else {
          isSocialSubmitLoading = false;
          update();
          CustomSnackBar.error(errorList: loginModel.message?.error ?? [MyStrings.loginFailedTryAgain.tr]);
        }
      } else {
        isSocialSubmitLoading = false;
        update();
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e.toString());
    }

    isGoogle = false;
    isLinkedin = false;
    isSocialSubmitLoading = false;
    update();
  }

  Future<bool> checkUserAccessTokenSaved() async {
    final token = await loginRepo.apiClient.getAccessToken();
    return token.isNotEmpty && token != 'null';
  }
}
