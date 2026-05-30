import 'package:esim/core/utils/method.dart';
import 'package:esim/core/utils/url_container.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/services/api_service.dart';

class StoreRepo {
  ApiClient apiClient;
  StoreRepo({required this.apiClient});

  Future<ResponseModel> getCountries(String page, {String search = ''}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.countriesEndPoint}?page=$page";
    if (search.isNotEmpty) url += "&search=$search";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getRegions(String page, {String search = ''}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.regionsEndPoint}?page=$page";
    if (search.isNotEmpty) url += "&search=$search";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getGlobalPlansCount() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.storeEndPoint}";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }
}
