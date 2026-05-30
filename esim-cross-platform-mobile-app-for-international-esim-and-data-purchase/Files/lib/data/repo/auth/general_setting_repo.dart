import 'package:esim/core/utils/method.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/url_container.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/services/api_service.dart';
import 'package:esim/environment.dart';

class GeneralSettingRepo {
  ApiClient apiClient;
  GeneralSettingRepo({required this.apiClient});

  Future<dynamic> getGeneralSetting() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.generalSettingEndPoint}';
    ResponseModel response = await apiClient.request(url, Method.getMethod, null, passHeader: true, isOnlyAcceptType: true, headers: {
      "custom-string": Environment.appAuthKey,
    });
    return response;
  }

  Future<dynamic> getLanguage(String languageCode) async {
    try {
      String url = '${UrlContainer.baseUrl}${UrlContainer.languageUrl}$languageCode';
      ResponseModel response = await apiClient.request(url, Method.getMethod, null, passHeader: false);
      return response;
    } catch (e) {
      return ResponseModel(false, MyStrings.somethingWentWrong, 300, '');
    }
  }

  Future<dynamic> loadOnboardData() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.onBoardsApiEndPoint}';
    final response = await apiClient.request(url, Method.getMethod, null);
    return response;
  }
}
