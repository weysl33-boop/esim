import 'dart:convert';

import 'package:get/get.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/utils/method.dart';
import 'package:esim/core/utils/url_container.dart';
import 'package:esim/data/model/authorization/authorization_response_model.dart';
import 'package:esim/data/model/global/kyc/global_kyc_form_data.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:esim/view/components/snack_bar/show_custom_snackbar.dart';

class PaymentMethodRepo implements ApiMethodRepo {
  @override
  Future<ResponseModel> getAllData(int page) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.paymentMethods}?page=$page';
    ResponseModel response = await apiClient.request(url, Method.getMethod, {}, passHeader: true);
    return response;
  }

  Future<ResponseModel> deleteMethod(String id) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.deletePaymentMethods}/$id';
    ResponseModel response = await apiClient.request(url, Method.postMethod, {}, passHeader: true);
    return response;
  }

  Future<ResponseModel> getCreateData() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.createPaymentMethods}';
    ResponseModel response = await apiClient.request(url, Method.getMethod, {}, passHeader: true);
    return response;
  }

  Future<ResponseModel> getEditData(String id) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.editPaymentMethods}/$id';
    ResponseModel response = await apiClient.request(url, Method.getMethod, {}, passHeader: true);
    return response;
  }

  Future<bool> saveData({
    required String methodId,
    required List<GlobalFormModel> list,
    String? remark,
    String? paramsId = '',
  }) async {
    apiClient.initToken();
    try {
      await modelToMap(list);
      Map<String, String> finalMap = {
        'payment_method': methodId,
        'remark': remark ?? '',
      };

      String url = '${UrlContainer.baseUrl}${UrlContainer.savePaymentMethods}${paramsId != '' ? '/$paramsId' : ''}';
      var request = http.MultipartRequest('POST', Uri.parse(url));

      for (var element in fieldList) {
        finalMap.addAll(element);
      }
      printX(finalMap.toString());

      request.headers.addAll(<String, String>{'Authorization': 'Bearer ${apiClient.token}'});

      for (var file in filesList) {
        request.files.add(http.MultipartFile(file.key ?? '', file.value.readAsBytes().asStream(), file.value.lengthSync(), filename: file.value.path.split('/').last));
      }

      request.fields.addAll(finalMap);

      http.StreamedResponse response = await request.send();

      String jsonResponse = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(jsonResponse));
        if (model.status == "success") {
          Get.back();
          CustomSnackBar.success(successList: model.message?.success ?? []);
          return true;
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? []);
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      printX(e);
      return false;
    }
  }

  @override
  Future<ResponseModel> getDetails(String id) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.paymentMethods}/$id';
    ResponseModel response = await apiClient.request(url, Method.getMethod, {}, passHeader: true);
    return response;
  }

  List<Map<String, String>> fieldList = [];
  List<ModelDynamicValue> filesList = [];

  Future<dynamic> modelToMap(List<GlobalFormModel> list) async {
    for (var e in list) {
      if (e.type == 'checkbox') {
        if (e.cbSelected != null && e.cbSelected!.isNotEmpty) {
          for (int i = 0; i < e.cbSelected!.length; i++) {
            fieldList.add({'${e.label}[$i]': e.cbSelected![i]});
          }
        }
      } else if (e.type == 'file') {
        if (e.imageFile != null) {
          filesList.add(ModelDynamicValue(e.label, e.imageFile!));
        }
      } else {
        if (e.selectedValue != null && e.selectedValue.toString().isNotEmpty) {
          fieldList.add({e.label ?? '': e.selectedValue});
        }
      }
    }
  }

//
  @override
  ApiClient apiClient = Get.find();
}

class ModelDynamicValue {
  String? key;
  dynamic value;
  ModelDynamicValue(this.key, this.value);
}

abstract class ApiMethodRepo {
  ApiClient apiClient = Get.find();
  Future<ResponseModel> getAllData(int page);
  Future<ResponseModel> getDetails(String id);
}
