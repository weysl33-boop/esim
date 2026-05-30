import 'dart:convert';

import 'package:esim/core/helper/shared_preference_helper.dart';
import 'package:get/get.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/data/model/general_setting/general_setting_response_model.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/repo/auth/login_repo.dart';

import '../../repo/auth/signup_repo.dart';

class AuthenticationController extends GetxController with GetSingleTickerProviderStateMixin {
  LoginRepo loginRepo;
  RegistrationRepo registrationRepo;
  AuthenticationController({required this.loginRepo, required this.registrationRepo});

  void getGSData() async {
    try {
      ResponseModel response = await loginRepo.getGeneralSetting();

      if (response.statusCode == 200) {
        GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(response.responseJson));
        if (model.status?.toLowerCase() == MyStrings.success) {
          loginRepo.apiClient.storeGeneralSetting(model);
          update();
        } else {
          // List<String> message = [MyStrings.somethingWentWrong];
          // CustomSnackBar.error(errorList: model.message?.error ?? message);
        }
      } else {
        // CustomSnackBar.error(errorList: [response.message]);
      }
    } catch (e) {
      printX(e.toString());
    }
  }

  Future<void> clearSharedPrefData() async {
    await loginRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userNameKey, '');
    await loginRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userEmailKey, '');
    await loginRepo.apiClient.clearOldAuthData();
    await loginRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
    return Future.value();
  }
}
