import 'dart:convert';
import 'package:get/get.dart';
import 'package:esim/core/helper/shared_preference_helper.dart';
import 'package:esim/core/route/route.dart';
import 'package:esim/core/utils/method.dart';
import 'package:esim/core/utils/messages.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/url_container.dart';
import 'package:esim/data/model/authorization/authorization_response_model.dart';
import 'package:esim/data/controller/localization/localization_controller.dart';
import 'package:esim/data/model/general_setting/general_setting_response_model.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/repo/auth/general_setting_repo.dart';
import 'package:esim/data/model/user/user_model.dart';
import 'package:esim/view/components/snack_bar/show_custom_snackbar.dart';

import '../../../core/helper/string_format_helper.dart';
import '../../../environment.dart';
import '../../model/onboard/onboard_model.dart';

class SplashController extends GetxController {
  GeneralSettingRepo repo;
  LocalizationController localizationController;

  SplashController({required this.repo, required this.localizationController});

  bool isLoading = true;

  Future<void> gotoNextPage() async {
    await loadLanguage();
    bool isRemember = repo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ?? false;
    final hasToken = await _hasValidToken();
    bool isFirstTime = repo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.firstTimeOnAppKey) ?? true; // we need to check it bcz for first time we will redirect to sign up page
    bool isOnboardEnable = repo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.onBoardIsOnKey) ?? true;
    noInternet = false;
    update();

    initSharedData();
    getGSData(isRemember || hasToken, isFirstTime, isOnboardEnable);
  }

  bool noInternet = false;

  void getGSData(bool isRemember, bool isFirstTime, bool isOnboardEnable) async {
    try {
      ResponseModel response = await repo.getGeneralSetting();

      if (response.statusCode == 200) {
        GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(response.responseJson));
        if (model.status?.toLowerCase() == MyStrings.success) {
          repo.apiClient.storeGeneralSetting(model);
        } else {
          List<String> message = [MyStrings.somethingWentWrong];
          CustomSnackBar.error(errorList: model.message?.error ?? message);
        }
      } else {
        if (response.statusCode == 503) {
          noInternet = true;
          update();
        }
        CustomSnackBar.error(errorList: [response.message]);
      }

      isLoading = false;
      update();
      if (isFirstTime) {
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAndToNamed(RouteHelper.welcomeScreen);
        });
      } else {
        if (isRemember) {
          _goToRememberedUserNextStep();
        } else {
          if (Environment.isGuestModeEnable) {
            Future.delayed(const Duration(seconds: 1), () {
              Get.offAndToNamed(RouteHelper.dashboardScreen);
            });
          } else {
            bool isShouldOpenLoginTab = isFirstTime ? false : true;
            Future.delayed(const Duration(seconds: 1), () {
              Get.offAndToNamed(RouteHelper.authenticationScreen, arguments: isShouldOpenLoginTab);
            });
          }
        }
      }
    } catch (e) {
      printX(e);
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAndToNamed(RouteHelper.authenticationScreen, arguments: true); // true means we will redirect to authentication page login tab
      });
    }
  }

  Future<void> _goToRememberedUserNextStep() async {
    final nextStep = await _resolveRememberedUserRoute();
    Future.delayed(const Duration(seconds: 1), () {
      Get.offAndToNamed(nextStep.route, arguments: nextStep.arguments);
    });
  }

  Future<_SplashNavigationStep> _resolveRememberedUserRoute() async {
    final token = await repo.apiClient.getAccessToken();

    if (token.isEmpty || token == 'null') {
      return const _SplashNavigationStep(RouteHelper.authenticationScreen, true);
    }

    try {
      final url = '${UrlContainer.baseUrl}${UrlContainer.authorizationCodeEndPoint}';
      final response = await repo.apiClient.request(url, Method.getMethod, null, passHeader: true, needAuthCheck: false);

      if (response.statusCode != 200) {
        return const _SplashNavigationStep(RouteHelper.authenticationScreen, true);
      }

      final model = AuthorizationResponseModel.fromJson(jsonDecode(response.responseJson));
      final user = model.data?.user;

      if (model.remark == 'profile_incomplete') {
        return const _SplashNavigationStep(RouteHelper.profileCompleteScreen);
      }

      if (model.remark == 'unverified' && user != null) {
        return _verificationStepForUser(user);
      }

      if (model.remark == 'unauthenticated') {
        return const _SplashNavigationStep(RouteHelper.authenticationScreen, true);
      }

      // API can return {"remark":"already_verified","status":"error"} for /authorization
      // even when the session is valid. Treat this as logged-in state.
      if (model.remark == 'already_verified') {
        return const _SplashNavigationStep(RouteHelper.dashboardScreen);
      }

      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        return const _SplashNavigationStep(RouteHelper.dashboardScreen);
      }

      return const _SplashNavigationStep(RouteHelper.authenticationScreen, true);
    } catch (e) {
      printX(e.toString());
      return const _SplashNavigationStep(RouteHelper.authenticationScreen, true);
    }
  }

  Future<bool> _hasValidToken() async {
    final token = await repo.apiClient.getAccessToken();
    return token.isNotEmpty && token != 'null';
  }

  _SplashNavigationStep _verificationStepForUser(User user) {
    final needEmailVerification = user.ev != '1';
    final needSmsVerification = user.sv != '1';
    final needTwoFactorVerification = user.tv != '1';
    final isProfileCompleteEnable = user.profileComplete == '0';

    if (!needEmailVerification && !needSmsVerification && !needTwoFactorVerification) {
      if (isProfileCompleteEnable) {
        return const _SplashNavigationStep(RouteHelper.profileCompleteScreen);
      }
      return const _SplashNavigationStep(RouteHelper.dashboardScreen);
    }

    if (needEmailVerification) {
      return _SplashNavigationStep(
        RouteHelper.emailVerificationScreen,
        [needSmsVerification, isProfileCompleteEnable, needTwoFactorVerification],
      );
    }

    if (needSmsVerification) {
      return _SplashNavigationStep(
        RouteHelper.smsVerificationScreen,
        [isProfileCompleteEnable, needTwoFactorVerification],
      );
    }

    if (needTwoFactorVerification) {
      return _SplashNavigationStep(RouteHelper.twoFactorScreen, isProfileCompleteEnable);
    }

    return const _SplashNavigationStep(RouteHelper.dashboardScreen);
  }

  Future<bool> initSharedData() {
    if (!repo.apiClient.sharedPreferences.containsKey(SharedPreferenceHelper.countryCode)) {
      return repo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.countryCode, MyStrings.myLanguages[0].countryCode);
    }
    if (!repo.apiClient.sharedPreferences.containsKey(SharedPreferenceHelper.languageCode)) {
      return repo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.languageCode, MyStrings.myLanguages[0].languageCode);
    }
    return Future.value(true);
  }

  Future<void> loadLanguage() async {
    localizationController.loadCurrentLanguage();
    String languageCode = localizationController.locale.languageCode;
    try {
      ResponseModel response = await repo.getLanguage(languageCode);
      if (response.statusCode == 200) {
        Map<String, Map<String, String>> language = {};
        saveLanguageList(response.responseJson);
        var resJson = jsonDecode(response.responseJson);
        await repo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.languageListKey, response.responseJson);
        var langKeyList = resJson['data']['file'].toString() == '[]' ? {} : resJson['data']['file'];
        Map<String, String> json = {};
        if (langKeyList is Map<String, dynamic>) {
          langKeyList.forEach((key, value) {
            json[key] = value.toString();
          });
        }
        language['${localizationController.locale.languageCode}_${localizationController.locale.countryCode}'] = json;
        Get.addTranslations(Messages(languages: language).keys);
      } else {
        CustomSnackBar.error(errorList: [response.message]);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: [e.toString()]);
    }
  }

  void saveLanguageList(String languageJson) async {
    await repo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.languageListKey, languageJson);
    return;
  }

  bool isOnBoardLoading = false;
  List<OnBoard> onboardList = [];
  String onboardImagePath = "";

  Future<void> getAllOnboardDataList() async {
    isOnBoardLoading = true;
    update();
    try {
      ResponseModel responseModel = await repo.loadOnboardData();
      if (responseModel.statusCode == 200) {
        OnBoardResponseModel model = onBoardsFromJson(responseModel.responseJson);
        if (model.status == MyStrings.success) {
          List<OnBoard>? tempListData = model.data?.onBoards;
          onboardImagePath = model.data?.imagePath ?? '';
          if (tempListData != null && tempListData.isNotEmpty) {
            onboardList.addAll(tempListData);
          }
        } else {
          // CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e.toString());
    }

    if (onboardList.isEmpty) {
      Get.offAndToNamed(RouteHelper.authenticationScreen, arguments: false);
    }

    isOnBoardLoading = false;
    update();
  }
}

class _SplashNavigationStep {
  final String route;
  final dynamic arguments;

  const _SplashNavigationStep(this.route, [this.arguments]);
}
