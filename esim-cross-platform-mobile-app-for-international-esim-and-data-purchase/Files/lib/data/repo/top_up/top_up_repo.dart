import 'package:esim/core/utils/method.dart';
import 'package:esim/core/utils/url_container.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/services/api_service.dart';

class TopupRepo {
  ApiClient apiClient;
  TopupRepo({required this.apiClient});

  Future<ResponseModel> getStoreDetailsRepo(String page, String planId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.topUpPlans}$planId?page=$page";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getPlanRepo(String uid, String planId) async {
    Map<String, String> map = {
      'uid': uid,
    };
    String url = "${UrlContainer.baseUrl}${UrlContainer.topUpPaymentInitiate}$planId";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      map,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getRegions(String page, String planId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.validCountries}?plan_id=$planId&page=$page";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getGlobalPlansCount() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.storeEndPoint}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }
}
