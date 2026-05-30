import 'package:esim/core/utils/method.dart';
import 'package:esim/core/utils/url_container.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/services/api_service.dart';

class StoreDetailsRepo {
  ApiClient apiClient;
  StoreDetailsRepo({required this.apiClient});

  Future<ResponseModel> getStoreDetailsRepo(String page, String planId, bool isFromCamapign, bool isRegion) async {
    String url = "${UrlContainer.baseUrl}${planId == "0" ? UrlContainer.globalPlan : isRegion ? "${UrlContainer.continentalPlan}/$planId?page=$page" : isFromCamapign ? "${UrlContainer.campaignPlansDetails}$planId?page=$page" : "${UrlContainer.storeDetails}$planId?page=$page"}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getPlanRepo(String planId) async {
    Map<String, String> map = {
      'plan_id': planId,
    };
    String url = "${UrlContainer.baseUrl}${UrlContainer.getPlanId}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      map,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getRegions(
    String page,
    String planId,
    String search,
  ) async {
    String url = "${UrlContainer.baseUrl}countries?search=$search&plan_id=$planId&page=$page";

    return await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
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
