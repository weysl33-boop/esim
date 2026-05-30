import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esim/core/helper/shared_preference_helper.dart';
import 'package:esim/core/route/route.dart';
import 'package:esim/core/utils/method.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/url_container.dart';
import 'package:esim/data/model/authorization/authorization_response_model.dart';
import 'package:esim/data/model/general_setting/general_setting_response_model.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';

import '../../core/helper/string_format_helper.dart';

class ApiClient extends GetxService {
  SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;
  ApiClient({
    required this.sharedPreferences,
    FlutterSecureStorage? secureStorage,
  }) : secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<ResponseModel> request(
    String uri,
    String method,
    Map<String, dynamic>? params, {
    bool passHeader = false,
    bool isOnlyAcceptType = false,
    bool needAuthCheck = true,
    Map<String, String>? headers,
  }) async {
    Uri url = Uri.parse(uri);
    http.Response response;

    try {
      if (method == Method.postMethod) {
        if (passHeader) {
          await initToken();
          if (isOnlyAcceptType) {
            response = await http.post(url, body: params, headers: _buildHeaders(includeAuth: false, extraHeaders: headers));
          } else {
            response = await http.post(url, body: params, headers: _buildHeaders(extraHeaders: headers));
          }
        } else {
          response = await http.post(url, body: params);
        }
      } else if (method == Method.deleteMethod) {
        if (passHeader) {
          await initToken();
          response = await http.delete(url, body: params, headers: _buildHeaders(extraHeaders: headers));
        } else {
          response = await http.delete(url, body: params);
        }
      } else if (method == Method.updateMethod) {
        if (passHeader) {
          await initToken();
          response = await http.patch(url, body: params, headers: _buildHeaders(extraHeaders: headers));
        } else {
          response = await http.patch(url, body: params);
        }
      } else {
        if (passHeader) {
          await initToken();
          response = await http.get(url, headers: _buildHeaders(extraHeaders: headers));
        } else {
          response = await http.get(
            url,
          );
        }
      }

      printX('url--------------${uri.toString()}');
      printX('params-----------${params.toString()}');
      printX('status-----------${response.statusCode}');
      printX('body-------------${response.body.toString()}');
      printX('token------------$token');

      if (response.statusCode == 200) {
        if (response.body.toString() != '') {
          try {
            AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(response.body));
            final isDirectAuthRequest = uri == '${UrlContainer.baseUrl}${UrlContainer.loginEndPoint}' || uri == '${UrlContainer.baseUrl}${UrlContainer.socialLoginEndPoint}';
            final isDeviceTokenRequest = uri == '${UrlContainer.baseUrl}${UrlContainer.deviceTokenEndPoint}';
            final shouldSkipGlobalAuthRouting = isDirectAuthRequest || isDeviceTokenRequest;

            if (!shouldSkipGlobalAuthRouting) {
              if (model.remark == 'profile_incomplete') {
                Get.toNamed(RouteHelper.profileCompleteScreen);
              } else if (model.remark == 'kyc_verification') {
                Get.offAndToNamed(RouteHelper.kycScreen);
              } else if (model.remark == 'unauthenticated') {
                if (needAuthCheck) {
                  sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
                  await clearOldAuthData();
                  Get.toNamed(RouteHelper.authenticationScreen);
                }
              } else if (model.remark == 'unverified' && uri != '${UrlContainer.baseUrl}${UrlContainer.getProfileEndPoint}' && uri != '${UrlContainer.baseUrl}${UrlContainer.authorizationCodeEndPoint}') {
                checkAndGotoNextStep(model);
              }
            }
          } catch (e) {
            printX(e.toString());
          }
        }

        return ResponseModel(true, 'success', 200, response.body);
      } else if (response.statusCode == 401) {
        await clearOldAuthData();
        sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
        Get.offAllNamed(RouteHelper.authenticationScreen);
        return ResponseModel(false, MyStrings.unAuthorized.tr, 401, response.body);
      } else if (response.statusCode == 500) {
        return ResponseModel(false, MyStrings.serverError.tr, 500, response.body);
      } else if (response.body.toString() != '') {
        return ResponseModel(false, 'error', response.statusCode, response.body);
      } else {
        return ResponseModel(false, MyStrings.somethingWentWrong.tr, 499, response.body);
      }
    } on SocketException {
      return ResponseModel(false, MyStrings.noInternet.tr, 503, '');
    } on FormatException {
      return ResponseModel(false, MyStrings.badResponseMsg.tr, 400, '');
    } catch (e) {
      printX(e);
      return ResponseModel(false, MyStrings.somethingWentWrong.tr, 499, '');
    }
  }

  String token = '';
  String tokenType = '';

  Map<String, String> _buildHeaders({
    bool includeAuth = true,
    Map<String, String>? extraHeaders,
  }) {
    return {
      "Accept": "application/json",
      if (includeAuth) "Authorization": "$tokenType $token",
      ...?extraHeaders,
    };
  }

  Future<void> initToken() async {
    token = await getAccessToken();
    tokenType = await getAccessTokenType();
  }

  Future<void> storeAuthTokenData({
    required String accessToken,
    required String accessType,
  }) async {
    await secureStorage.write(key: SharedPreferenceHelper.accessTokenKey, value: accessToken);
    await secureStorage.write(key: SharedPreferenceHelper.accessTokenType, value: accessType);
  }

  Future<String> getAccessToken() async {
    final secureToken = await secureStorage.read(key: SharedPreferenceHelper.accessTokenKey);
    if (secureToken != null && secureToken.isNotEmpty && secureToken != 'null') {
      return secureToken;
    }
    return '';
  }

  Future<String> getAccessTokenType() async {
    final secureType = await secureStorage.read(key: SharedPreferenceHelper.accessTokenType);
    if (secureType != null && secureType.isNotEmpty && secureType != 'null') {
      return secureType;
    }
    return 'Bearer';
  }

  void checkAndGotoNextStep(AuthorizationResponseModel responseModel) async {
    // bool isBan = responseModel.data?.user?.status == "1" ? false : true;
    bool needEmailVerification = responseModel.data?.user?.ev == "1" ? false : true;
    bool needSmsVerification = responseModel.data?.user?.sv == '1' ? false : true;
    bool isTwoFactorEnable = responseModel.data?.user?.tv == '1' ? false : true;

    bool isProfileCompleteEnable = responseModel.data?.user?.profileComplete == '0' ? true : false;

    if (isProfileCompleteEnable) {
      Get.offAndToNamed(RouteHelper.profileCompleteScreen);
    } else if (needEmailVerification) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen);
    } else if (needSmsVerification) {
      Get.offAndToNamed(RouteHelper.smsVerificationScreen);
    } else if (isTwoFactorEnable) {
      Get.offAndToNamed(RouteHelper.twoFactorScreen);
    }
  }

  void storeGeneralSetting(GeneralSettingResponseModel model) {
    String json = jsonEncode(model.toJson());
    sharedPreferences.setString(SharedPreferenceHelper.generalSettingKey, json);
    getGSData();
  }

  GeneralSettingResponseModel getGSData() {
    String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
    GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
    return model;
  }

  String getCurrencyOrUsername({bool isCurrency = true, bool isSymbol = false}) {
    if (isCurrency) {
      String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
      String currency = isSymbol ? model.data?.generalSetting?.curSym ?? '' : model.data?.generalSetting?.curText ?? '';
      return currency;
    } else {
      String username = sharedPreferences.getString(SharedPreferenceHelper.userNameKey) ?? '';
      return username;
    }
  }

  int getDecimalAfterNumber() {
    try {
      String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
      int result = int.parse(model.data?.generalSetting?.allowDecimalAfterNumber ?? '4');
      return result;
    } catch (e) {
      return 4;
    }
  }

  String getChargePercent({bool isUserCharge = true}) {
    try {
      String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
      String result = isUserCharge ? model.data?.generalSetting?.otherUserTransferCharge ?? '0' : model.data?.generalSetting?.p2PTradeCharge ?? '0';
      return result;
    } catch (e) {
      return '0';
    }
  }

  WalletTypes? getWalletTypes() {
    String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
    GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
    WalletTypes? result = model.data?.generalSetting?.walletTypes;
    return result;
  }

  String getUserEmail() {
    String email = sharedPreferences.getString(SharedPreferenceHelper.userEmailKey) ?? '';
    return email;
  }

  String getUserID() {
    String idKey = sharedPreferences.getString(SharedPreferenceHelper.userIdKey) ?? '';
    return idKey;
  }

  bool getPasswordStrengthStatus() {
    String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
    GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
    bool checkPasswordStrength = model.data?.generalSetting?.securePassword.toString() == '0' ? false : true;
    return checkPasswordStrength;
  }

  GeneralSetting getGeneralSettingsData() {
    try {
      String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
      GeneralSetting social = model.data?.generalSetting ?? GeneralSetting();
      return social;
    } catch (e) {
      return GeneralSetting();
    }
  }

  SocialiteCredentials getSocialCredentialsConfigData() {
    try {
      String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
      SocialiteCredentials social = model.data?.generalSetting?.socialiteCredentials ?? SocialiteCredentials();
      return social;
    } catch (e) {
      return SocialiteCredentials();
    }
  }

  bool getSocialCredentialsEnabledAll() {
    try {
      return getSocialCredentialsConfigData().google?.status == '1' && getSocialCredentialsConfigData().linkedin?.status == '1';
    } catch (e) {
      return false;
    }
  }

  bool isAnySocialLoginEnabled() {
    final googleEnabled = getSocialCredentialsConfigData().google?.status == '1';
    final linkedInEnabled = getSocialCredentialsConfigData().linkedin?.status == '1';
    return googleEnabled || linkedInEnabled;
  }

  String getSocialCredentialsRedirectUrl() {
    String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
    GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
    String redirect = model.data?.socialLoginRedirect ?? "";
    return redirect;
  }

  String getTemplateName() {
    String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
    GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
    String templateName = model.data?.generalSetting?.activeTemplate ?? '';
    return templateName;
  }

  Future<void> clearOldAuthData() async {
    await sharedPreferences.remove(SharedPreferenceHelper.userIdKey);
    await sharedPreferences.remove(SharedPreferenceHelper.userEmailKey);
    await sharedPreferences.remove(SharedPreferenceHelper.userPhoneNumberKey);
    await sharedPreferences.remove(SharedPreferenceHelper.userNameKey);
    // Tokens are stored only in secure storage.
    await secureStorage.delete(key: SharedPreferenceHelper.accessTokenKey);
    await secureStorage.delete(key: SharedPreferenceHelper.accessTokenType);
  }
}
