// To parse this JSON data, do
//
//     final paymentMethodCreateResponseModel = paymentMethodCreateResponseModelFromJson(jsonString);

import 'dart:convert';
import 'package:esim/data/model/auth/login/login_response_model.dart';
import 'package:esim/data/model/payment_method/payment_method_create_response.dart';

PaymentMethodEditResponseModel paymentMethodCreateResponseModelFromJson(String str) => PaymentMethodEditResponseModel.fromJson(json.decode(str));

String paymentMethodCreateResponseModelToJson(PaymentMethodEditResponseModel data) => json.encode(data.toJson());

class PaymentMethodEditResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  PaymentMethodEditResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory PaymentMethodEditResponseModel.fromJson(Map<String, dynamic> json) => PaymentMethodEditResponseModel(
        remark: json["remark"],
        status: json["status"],
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "remark": remark,
        "status": status,
        "message": message?.toJson(),
        "data": data?.toJson(),
      };
}

class Data {
  List<CreatePaymentMethodData>? methods;
  EditPaymentMethodData? paymentMethod;

  Data({this.methods, this.paymentMethod});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        methods: json["methods"] == null ? [] : List<CreatePaymentMethodData>.from(json["methods"]!.map((x) => CreatePaymentMethodData.fromJson(x))),
        paymentMethod: json["payment_method"] == null ? null : EditPaymentMethodData.fromJson((json["payment_method"])),
      );

  Map<String, dynamic> toJson() => {
        "payment_method": paymentMethod,
        "methods": methods?.map((x) => x.toJson()).toList(),
      };
}

class EditPaymentMethodData {
  String? id;
  String? userId;
  String? paymentMethodId;
  List<UserData>? userData;
  String? remark;
  String? createdAt;
  String? updatedAt;

  EditPaymentMethodData({
    this.id,
    this.userId,
    this.paymentMethodId,
    this.userData,
    this.remark,
    this.createdAt,
    this.updatedAt,
  });

  factory EditPaymentMethodData.fromJson(Map<String, dynamic> json) => EditPaymentMethodData(
        id: json["id"].toString(),
        userId: json["user_id"].toString(),
        paymentMethodId: json["payment_method_id"].toString(),
        userData: json["user_data"] == null ? [] : List<UserData>.from(json["user_data"]!.map((x) => UserData.fromJson(x))),
        remark: json["remark"],
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "payment_method_id": paymentMethodId,
        "user_data": userData == null ? [] : List<UserData>.from(userData!.map((x) => x.toJson())),
        "remark": remark,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

class UserData {
  String? name;
  String? type;
  String? value;

  UserData({
    this.name,
    this.type,
    this.value,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        name: json["name"],
        type: json["type"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "type": type,
        "value": value,
      };
}
