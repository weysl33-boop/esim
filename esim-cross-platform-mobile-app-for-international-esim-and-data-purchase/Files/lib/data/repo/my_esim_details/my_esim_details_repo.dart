import 'package:esim/core/utils/method.dart';
import 'package:esim/core/utils/url_container.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/services/api_service.dart';

class MyEsimDetailsRepo {
  ApiClient apiClient;
  MyEsimDetailsRepo({required this.apiClient});
  Future<ResponseModel> getActiveEsimData(String id) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.myActiveEsimData}$id";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }
}
