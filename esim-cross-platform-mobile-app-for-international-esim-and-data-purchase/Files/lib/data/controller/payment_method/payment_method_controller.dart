// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/helper/date_converter.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/util.dart';
import 'package:esim/data/model/authorization/authorization_response_model.dart';
import 'package:esim/data/model/global/kyc/global_kyc_form_data.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/model/payment_method/payment_method_create_response.dart';
import 'package:esim/data/model/payment_method/payment_method_edit_response.dart';
import 'package:esim/data/model/payment_method/payment_method_list_response.dart';
import 'package:esim/data/repo/payment_method/payment_method_repo.dart';
import 'package:esim/view/components/snack_bar/show_custom_snackbar.dart';

class PaymentMethodController extends GetxController implements MethodController {
  PaymentMethodRepo repo;
  PaymentMethodController() : repo = Get.put<PaymentMethodRepo>(Get.find());

  bool isLoading = true;
  int page = 1;
  List<PaymentMethodData> methodList = [];
  String? nextPageUrl;
  @override
  initData({bool shouldLoading = true}) {
    page = 0;
    update();
    getData(shouldLoading: shouldLoading);
  }

  @override
  Future<void> deleteMethod(String id) async {
    isSubmitLoading = true;
    update();
    try {
      ResponseModel responseModel = await repo.deleteMethod(id);
      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == "success") {
          Get.back();
          CustomSnackBar.success(successList: model.message?.success ?? []);
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e);
    } finally {
      isSubmitLoading = false;

      initData(shouldLoading: false);
    }
  }

  @override
  Future<void> getData({bool shouldLoading = true}) async {
    page = page + 1;
    isLoading = shouldLoading;
    update();
    try {
      ResponseModel responseModel = await repo.getAllData(page);
      if (responseModel.statusCode == 200) {
        PaymentMethodListResponseModel model = PaymentMethodListResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == "success") {
          if (page == 1) {
            methodList = [];
          }
          nextPageUrl = model.data?.paymentMethod?.nextPageUrl;
          methodList.addAll(model.data?.paymentMethod?.data ?? []);
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e);
    } finally {
      isLoading = false;
      update();
    }
  }

  List<CreatePaymentMethodData> paymentMethods = [];
  TextEditingController remarkController = TextEditingController();

  @override
  Future<void> createData() async {
    isLoading = true;
    paymentMethods = [];
    remarkController.text = '';
    update();
    try {
      ResponseModel responseModel = await repo.getCreateData();
      if (responseModel.statusCode == 200) {
        PaymentMethodCreateResponseModel model = PaymentMethodCreateResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == "success") {
          paymentMethods.insert(0, CreatePaymentMethodData(id: "-1", name: MyStrings.selectOne));
          paymentMethods.addAll(model.data?.paymentMethod ?? []);
          selectPaymentMethod(CreatePaymentMethodData(id: "-1", name: MyStrings.selectOne));
          update();
          printX("paymentMethods.length ${paymentMethods.length}");
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e);
    } finally {
      isLoading = false;
      update();
    }
  }

  String editId = "-1";
  Future<void> editMethod(String id) async {
    isLoading = true;
    paymentMethods = [];
    remarkController.text = '';
    update();
    try {
      ResponseModel responseModel = await repo.getEditData(id);
      if (responseModel.statusCode == 200) {
        PaymentMethodEditResponseModel model = PaymentMethodEditResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == "success") {
          paymentMethods.insert(0, CreatePaymentMethodData(id: "-1", name: MyStrings.selectOne));
          paymentMethods.addAll(model.data?.methods ?? []);
          remarkController.text = model.data?.paymentMethod?.remark ?? '';
          editId = model.data?.paymentMethod?.id ?? '';
          CreatePaymentMethodData find = paymentMethods.firstWhere((element) => element.id == model.data?.paymentMethod?.paymentMethodId);

          selectPaymentMethod(find, editPaymentMethod: model.data?.paymentMethod);
          update();
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e);
    } finally {
      isLoading = false;
      update();
    }
  }

  CreatePaymentMethodData selectedPaymentMethod = CreatePaymentMethodData(id: "-1", name: MyStrings.selectOne);
  List<GlobalFormModel> formList = [];

  void selectPaymentMethod(CreatePaymentMethodData method, {EditPaymentMethodData? editPaymentMethod}) {
    formList = [];
    selectedPaymentMethod = method;
    update();
    if (method.userData?.formData?.list?.isNotEmpty ?? false) {
      formList.addAll(method.userData?.formData?.list ?? []);
      if (editPaymentMethod != null) {
        for (var v in formList) {
          var getData = editPaymentMethod.userData?.where((e) => e.name == v.name).first;
          printX(getData?.value);
          // if (getData?.name == v.name) {
          //   printx("656556685+6+685 ${getData?.toJson()}");
          //   v.selectedValue = getData?.value; // Change to the desired new value
          // }
          if (MyUtils.getInputType(v.type ?? "text") || v.type == "date" || v.type == "datetime" || v.type == "time") {
            v.selectedValue = getData?.value; // Change to the desired new value
            v.textEditingController?.text = getData?.value ?? ""; // Change to the desired new value
          }
        }
      }
      update();
    }
  }

  bool isSubmitLoading = false;
  Future<void> addNewMethod() async {
    List<String> list = hasError();
    if (list.isNotEmpty) {
      CustomSnackBar.error(errorList: list);
      return;
    }
    isSubmitLoading = true;
    update();
    try {
      bool response = await repo.saveData(list: formList, methodId: selectedPaymentMethod.id ?? '', remark: remarkController.text);
      printX(response);
      if (response == true) {
        Get.back();
      }
    } catch (e) {
      printX(e);
    } finally {
      isSubmitLoading = false;
      page = 0;
      update();
    }
  }

  Future<void> submitEditMethod() async {
    List<String> list = hasError();
    if (list.isNotEmpty) {
      CustomSnackBar.error(errorList: list);
      return;
    }
    isSubmitLoading = true;
    update();

    try {
      bool response = await repo.saveData(list: formList, methodId: selectedPaymentMethod.id ?? '', remark: remarkController.text, paramsId: editId);
      printX(response);
      if (response == true) {
        editId = "";
        remarkController.text = '';
        selectPaymentMethod(CreatePaymentMethodData(id: "-1", name: MyStrings.selectOne));
        initData(shouldLoading: false);
        return;
      }
    } catch (e) {
      printX(e);
    } finally {
      isSubmitLoading = false;
      update();
    }
  }

  void changeSelectedValue(dynamic value, int index) {
    formList[index].selectedValue = value;
    update();
  }

  void changeSelectedRadioBtnValue(int listIndex, int selectedIndex) {
    formList[listIndex].selectedValue = formList[listIndex].options?[selectedIndex];
    update();
  }

  void changeSelectedCheckBoxValue(int listIndex, String value) {
    List<String> list = value.split('_');
    int index = int.parse(list[0]);
    bool status = list[1] == 'true' ? true : false;

    List<String>? selectedValue = formList[listIndex].cbSelected;

    if (selectedValue != null) {
      String? value = formList[listIndex].options?[index];
      if (status) {
        if (!selectedValue.contains(value)) {
          selectedValue.add(value!);
          formList[listIndex].cbSelected = selectedValue;
          update();
        }
      } else {
        if (selectedValue.contains(value)) {
          selectedValue.removeWhere((element) => element == value);
          formList[listIndex].cbSelected = selectedValue;
          update();
        }
      }
    } else {
      selectedValue = [];
      String? value = formList[listIndex].options?[index];
      if (status) {
        if (!selectedValue.contains(value)) {
          selectedValue.add(value!);
          formList[listIndex].cbSelected = selectedValue;
          update();
        }
      } else {
        if (selectedValue.contains(value)) {
          selectedValue.removeWhere((element) => element == value);
          formList[listIndex].cbSelected = selectedValue;
          update();
        }
      }
    }
  }

  void pickFile(int index, {List<String>? extention}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.custom, allowedExtensions: extention ?? ['jpg', 'png', 'jpeg', 'pdf', 'doc', 'docx']);

    if (result == null) return;

    formList[index].imageFile = File(result.files.single.path!);
    String fileName = result.files.single.name;
    formList[index].selectedValue = fileName;
    update();
    return;
  }

// date time v2.00
  //NEW DATE TIME
  void changeSelectedDateTimeValue(int index, BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        formList[index].selectedValue = DateConverter.estimatedDateTime(selectedDateTime);
        formList[index].textEditingController?.text = DateConverter.estimatedDateTime(selectedDateTime);

        update();
      }
    }

    update();
  }

  void changeSelectedDateOnlyValue(int index, BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final DateTime selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );

      formList[index].selectedValue = DateConverter.estimatedDate(selectedDateTime);
      formList[index].textEditingController?.text = DateConverter.estimatedDate(selectedDateTime);
      update();
    }

    update();
  }

  void changeSelectedTimeOnlyValue(int index, BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final DateTime selectedDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        pickedTime.hour,
        pickedTime.minute,
      );

      formList[index].selectedValue = DateConverter.estimatedTime(selectedDateTime);
      formList[index].textEditingController?.text = DateConverter.estimatedTime(selectedDateTime);
      printX(formList[index].textEditingController?.text);
      printX(formList[index].selectedValue);
      update();
    }

    update();
  }
// end date time function

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }

  List<String> hasError() {
    List<String> errorList = [];
    errorList.clear();
    if (formList.isNotEmpty) {
      for (var element in formList) {
        if (element.isRequired?.toLowerCase() == 'required') {
          if (element.type == 'checkbox') {
            if (element.cbSelected == null) {
              errorList.add('${element.name} ${MyStrings.isRequired}');
            }
          } else if (element.type == 'file') {
            if (element.imageFile == null) {
              errorList.add('${element.name} ${MyStrings.isRequired}');
            }
          } else {
            if (element.selectedValue == '' || element.selectedValue == MyStrings.selectOne) {
              errorList.add('${element.name} ${MyStrings.isRequired}');
            }
          }
        }
      }
    }

    return errorList;
  }
}

abstract class MethodController {
  void initData() {}
  Future<void> getData() async {}
  Future<void> createData() async {}
  Future<void> deleteMethod(String id) async {}
}
