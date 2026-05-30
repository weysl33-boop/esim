import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/data/model/general_setting/general_setting_response_model.dart';
import 'package:esim/data/model/profile/profile_response_model.dart';
import 'package:esim/data/repo/home/home_repo.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/url_container.dart';
import '../../model/dashboard/dashboard_response_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/user/user_model.dart';

class HomeController extends GetxController {
  HomeRepo homeRepo;
  HomeController({required this.homeRepo});

  bool isLoading = true;
  String email = "";
  String fullName = "";
  String username = "";
  String siteName = "";
  String profileImageUrl = '';
  String defaultCurrency = "";
  String defaultCurrencySymbol = "";
  String estimatedBalance = "0.0";
  String usernameValue = "";
  String campaignImagePath = "";
  ProfileResponseModel profileResponseModel = ProfileResponseModel();
  User? userData;
  List<PopularCountry>? popularCountries = [];
  List<Campaign> campaigns = [];

  GeneralSettingResponseModel generalSettingResponseModel = GeneralSettingResponseModel();

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad;

    showBalance = homeRepo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.showBalanceKey) ?? false;
    update();
    if (checkUserIsLoggedInOrNot()) {
      await loadProfileInfo();
    }
    // Future.wait([loadGeneralSettingsData(), loadDashboardData()]);
    await loadDashboardData();
    await loadGeneralSettingsData();
    usernameValue = homeRepo.apiClient.sharedPreferences.getString(SharedPreferenceHelper.userNameKey) ?? '';

    isLoading = false;
    update();
  }

  Future<void> loadGeneralSettingsData() async {
    defaultCurrency = homeRepo.apiClient.getCurrencyOrUsername();
    username = homeRepo.apiClient.getCurrencyOrUsername(isCurrency: false);
    email = homeRepo.apiClient.getUserEmail();
    defaultCurrencySymbol = homeRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    generalSettingResponseModel = homeRepo.apiClient.getGSData();
    siteName = generalSettingResponseModel.data?.generalSetting?.siteName ?? "";
  }

  File? imageFile;
  String country = '';
  String mobileNo = '';
  String userName = '';
  Future<void> loadProfileInfo() async {
    update();
    try {
      profileResponseModel = await homeRepo.loadProfileInfo();

      if (profileResponseModel.data != null && profileResponseModel.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        userData = profileResponseModel.data?.user;
      }
    } catch (e) {
      printX(e.toString());
    }
    update();
  }

  bool showBalance = false;
  Future<void> changeShowBalanceState() async {
    showBalance = !showBalance;
    await homeRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.showBalanceKey, showBalance);
    update();
  }

  //Dashboard data
  HomeDataResponseModel dashboardResponseModel = HomeDataResponseModel();
  User? user = User();
  Future<void> loadDashboardData() async {
    try {
      ResponseModel responseModel = await homeRepo.getDashboardData();

      if (responseModel.statusCode == 200) {
        dashboardResponseModel = homeDataResponseModelFromJson(responseModel.responseJson);

        if (dashboardResponseModel.status?.toLowerCase() == MyStrings.success) {
          user = dashboardResponseModel.data?.user;
          popularCountries = dashboardResponseModel.data?.popularCountries ?? [];
          campaigns = dashboardResponseModel.data?.campaigns ?? [];
          campaignImagePath = dashboardResponseModel.data?.campaginBannerUrl ?? "";
          user = dashboardResponseModel.data?.user ?? User();
          var imageUrl = dashboardResponseModel.data?.user?.image == null ? '' : '${dashboardResponseModel.data?.user?.image}';
          if (imageUrl.isNotEmpty && imageUrl != 'null') {
            profileImageUrl = '${UrlContainer.domainUrl}/assets/images/user/profile/$imageUrl';
          }
          await homeRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userNameKey, username);
          await homeRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userEmailKey, email);
        } else {
          await homeRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userNameKey, '');
          await homeRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userEmailKey, '');
          await homeRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
        }
      }
    } catch (e) {
      printX(e.toString());
    }
  }

  int page = 0;
  String marketListType = 'all';
  String? nextPageUrl;
  bool isMarketPairListDataLoading = true;

  String loadMarketPairDataType = 'all';

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }

  bool checkUserIsLoggedInOrNot() {
    return homeRepo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ?? false;
  }
}
