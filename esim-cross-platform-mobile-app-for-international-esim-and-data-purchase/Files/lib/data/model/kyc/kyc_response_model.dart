import 'package:flutter/foundation.dart';
import 'package:esim/data/model/kyc/kyc_form_model.dart';
import '../../../core/helper/string_format_helper.dart';
import '../auth/login/login_response_model.dart';

class KycResponseModel {
  KycResponseModel({
    String? remark,
    String? status,
    Message? message,
    Data? data,
  }) {
    _remark = remark;
    _status = status;
    _message = message;
    _data = data;
  }

  KycResponseModel.fromJson(dynamic json) {
    _remark = json['remark'];
    _status = json['status'] != null ? json['status'].toString() : '';
    _message = json['message'] != null ? Message.fromJson(json['message']) : null;
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  String? _remark;
  String? _status;
  Message? _message;
  Data? _data;

  String? get remark => _remark;
  String? get status => _status;
  Message? get message => _message;
  Data? get data => _data;
}

class Data {
  Data({
    FormData? form,
    List<KycPendingData>? kycPendingData,
    String? path,
  }) {
    _form = form;
    _kycPendingData = kycPendingData;
    _path = path;
  }

  Data.fromJson(dynamic json) {
    _form = json['form'] != null ? FormData.fromJson(json['form']) : null;
    _kycPendingData = json['kyc_data'] == null ? [] : List<KycPendingData>.from(json["kyc_data"]!.map((x) => KycPendingData.fromJson(x)));
    _path = json["path"];
  }
  FormData? _form;
  String? _path;
  List<KycPendingData>? _kycPendingData;

  FormData? get form => _form;
  List<KycPendingData>? get kycPendingData => _kycPendingData;
  String? get path => _path;
}

class FormData {
  FormData({List<KycFormModel>? list}) {
    _list = list;
  }

  List<KycFormModel>? _list = [];
  List<KycFormModel>? get list => _list;

  FormData.fromJson(dynamic json) {
    try {
      var map = Map.from(json).map((key, value) => MapEntry(key, value));
      List<KycFormModel>? list = map.entries
          .map(
            (e) => KycFormModel(e.value['name'], e.value['label'], e.value['is_required'], e.value['instruction'], e.value['extensions'], (e.value['options'] as List).map((e) => e as String).toList(), e.value['type'], ''),
          )
          .toList();

      if (list.isNotEmpty) {
        list.removeWhere((element) => element.toString().isEmpty);
        _list?.addAll(list);
      }
      _list;
    } catch (e) {
      if (kDebugMode) {
        printX(e.toString());
      }
    }
  }
}

class KycPendingData {
  String? name;
  String? type;
  String? value;

  KycPendingData({
    this.name,
    this.type,
    this.value,
  });

  factory KycPendingData.fromJson(Map<String, dynamic> json) => KycPendingData(
        name: json["name"],
        type: json["type"],
        value: json["value"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "type": type,
        "value": value,
      };
}
