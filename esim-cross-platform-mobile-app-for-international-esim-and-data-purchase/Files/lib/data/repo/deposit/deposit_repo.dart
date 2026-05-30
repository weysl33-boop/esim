import '../../../core/utils/method.dart';
import '../../../core/utils/url_container.dart';
import '../../model/global/response_model/response_model.dart';
import '../../services/api_service.dart';

class DepositRepo {
  ApiClient apiClient;
  DepositRepo({required this.apiClient});

  Future<ResponseModel> getDepositHistory({required int page, String searchText = ""}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.depositHistoryUrl}?page=$page&search=$searchText";

    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<dynamic> getDepositMethods() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.depositMethodUrl}';

    ResponseModel response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<dynamic> getUserDataRepo() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.userInfo}';

    ResponseModel response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> insertDeposit({
    required String methodCode,
    required String orderId,
    required String amount,
    required String currency,
    required String walletType,
    required bool isTopUp,
    required String planId,
    required String uid,
  }) async {
    final cleanUid = (uid == "null") ? "" : uid;
    String endpoint;
    if (isTopUp) {
      endpoint = UrlContainer.depositInsertUrl;
    } else if (cleanUid.isNotEmpty) {
      endpoint = "${UrlContainer.topUpPayment}$planId";
    } else {
      endpoint = UrlContainer.orderPayment;
    }

    String url = "${UrlContainer.baseUrl}$endpoint";
    Map<String, String> map = {};
    if (isTopUp) {
      map.addAll({
        "amount": amount,
        "method_code": methodCode,
        "currency": currency,
      });
    } else if (cleanUid.isNotEmpty) {
      map.addAll({
        "uid": uid,
        "gateway": walletType == "direct" ? methodCode : "main-balance",
        "currency": currency,
      });
    } else {
      map.addAll({
        "order_id": orderId,
        "gateway": walletType == "direct" ? methodCode : "main-balance",
        "currency": currency,
      });
    }

    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, map, passHeader: true);
    return responseModel;
  }

  Future<dynamic> getUserInfo() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.getProfileEndPoint}';

    ResponseModel response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }
}
