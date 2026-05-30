import 'dart:convert';
import 'package:esim/core/utils/method.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/url_container.dart';
import 'package:esim/data/model/general_setting/general_setting_response_model.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/model/profile/profile_response_model.dart';
import 'package:esim/data/services/api_service.dart';

import '../../../environment.dart';

class HomeRepo {
  ApiClient apiClient;
  HomeRepo({required this.apiClient});

  Future<ResponseModel> getDashboardData() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.dashBoardEndPoint}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ProfileResponseModel> loadProfileInfo() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.getProfileEndPoint}';

    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true, needAuthCheck: false);

    if (responseModel.statusCode == 200) {
      ProfileResponseModel model = ProfileResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      return model;
    } else {
      return ProfileResponseModel();
    }
  }

  Future<dynamic> refreshGeneralSetting() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.generalSettingEndPoint}';
    ResponseModel response = await apiClient.request(url, Method.getMethod, null, passHeader: false, headers: {
      "custom-string": Environment.appAuthKey,
    });

    if (response.statusCode == 200) {
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(response.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        apiClient.storeGeneralSetting(model);
      }
    }
  }
}
