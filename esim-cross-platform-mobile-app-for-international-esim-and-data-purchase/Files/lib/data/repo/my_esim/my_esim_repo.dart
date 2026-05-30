import 'package:esim/core/utils/method.dart';
import 'package:esim/core/utils/url_container.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/services/api_service.dart';

class MyEsimRepo {
  ApiClient apiClient;
  MyEsimRepo({required this.apiClient});
  Future<ResponseModel> getMyActiveEsimRepo(
    String page,
  ) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.myActiveEsim}?page=$page";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getMyExpiredEsimRepo(
    String page,
  ) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.myExpiredEsim}?page=$page";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }
}
