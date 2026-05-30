// To parse this JSON data, do
//
//     final paymentMethodCreateResponseModel = paymentMethodCreateResponseModelFromJson(jsonString);

import 'dart:convert';
import 'package:esim/data/model/auth/login/login_response_model.dart';
import 'package:esim/data/model/global/kyc/global_user_data.dart';

PaymentMethodCreateResponseModel paymentMethodCreateResponseModelFromJson(String str) => PaymentMethodCreateResponseModel.fromJson(json.decode(str));

String paymentMethodCreateResponseModelToJson(PaymentMethodCreateResponseModel data) => json.encode(data.toJson());

class PaymentMethodCreateResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  PaymentMethodCreateResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory PaymentMethodCreateResponseModel.fromJson(Map<String, dynamic> json) => PaymentMethodCreateResponseModel(
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
  List<CreatePaymentMethodData>? paymentMethod;

  Data({
    this.paymentMethod,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        paymentMethod: json["payment_method"] == null ? [] : List<CreatePaymentMethodData>.from(json["payment_method"]!.map((x) => CreatePaymentMethodData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "payment_method": paymentMethod == null ? [] : List<dynamic>.from(paymentMethod!.map((x) => x.toJson())),
      };
}

class CreatePaymentMethodData {
  String? id;
  String? name;
  String? slug;
  List<String>? supportedCurrency;
  String? status;
  String? remark;
  String? formId;
  String? image;
  String? brandingColor;
  String? createdAt;
  String? updatedAt;
  GlobalUserDetailsData? userData;

  CreatePaymentMethodData({
    this.id,
    this.name,
    this.slug,
    this.supportedCurrency,
    this.status,
    this.remark,
    this.formId,
    this.image,
    this.brandingColor,
    this.createdAt,
    this.updatedAt,
    this.userData,
  });

  factory CreatePaymentMethodData.fromJson(Map<String, dynamic> json) => CreatePaymentMethodData(
        id: json["id"].toString(),
        name: json["name"].toString(),
        slug: json["slug"].toString(),
        supportedCurrency: json["supported_currency"] == null ? [] : List<String>.from(json["supported_currency"]!.map((x) => x)),
        status: json["status"].toString(),
        remark: json["remark"] ?? '',
        formId: json["form_id"].toString(),
        image: json["image"].toString(),
        brandingColor: json["branding_color"].toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
        userData: json["user_data"] == null ? null : GlobalUserDetailsData.fromJson(json["user_data"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "supported_currency": supportedCurrency == null ? [] : List<dynamic>.from(supportedCurrency!.map((x) => x)),
        "status": status,
        "form_id": formId,
        "image": image,
        "branding_color": brandingColor,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "user_data": userData,
      };
}
