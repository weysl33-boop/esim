// To parse this JSON data, do
//
//     final paymentMethodListResponseModel = paymentMethodListResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:esim/data/model/auth/login/login_response_model.dart';

PaymentMethodListResponseModel paymentMethodListResponseModelFromJson(String str) => PaymentMethodListResponseModel.fromJson(json.decode(str));

String paymentMethodListResponseModelToJson(PaymentMethodListResponseModel data) => json.encode(data.toJson());

class PaymentMethodListResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  PaymentMethodListResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory PaymentMethodListResponseModel.fromJson(Map<String, dynamic> json) => PaymentMethodListResponseModel(
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
  PaymentMethodMain? paymentMethod;

  Data({
    this.paymentMethod,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        paymentMethod: json["payment_method"] == null ? null : PaymentMethodMain.fromJson(json["payment_method"]),
      );

  Map<String, dynamic> toJson() => {
        "payment_method": paymentMethod?.toJson(),
      };
}

class PaymentMethodMain {
  int? currentPage;
  List<PaymentMethodData>? data;
  dynamic nextPageUrl;

  PaymentMethodMain({
    this.currentPage,
    this.data,
    this.nextPageUrl,
  });

  factory PaymentMethodMain.fromJson(Map<String, dynamic> json) => PaymentMethodMain(
        currentPage: json["current_page"],
        data: json["data"] == null ? [] : List<PaymentMethodData>.from(json["data"]!.map((x) => PaymentMethodData.fromJson(x))),
        nextPageUrl: json["next_page_url"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
      };
}

class PaymentMethodData {
  String? id;
  String? userId;
  String? paymentMethodId;
  List<UserPaymentMethodData>? userData;
  String? remark;
  String? createdAt;
  String? updatedAt;
  PaymentMethod? paymentMethod;

  PaymentMethodData({
    this.id,
    this.userId,
    this.paymentMethodId,
    this.userData,
    this.remark,
    this.createdAt,
    this.updatedAt,
    this.paymentMethod,
  });

  factory PaymentMethodData.fromJson(Map<String, dynamic> json) => PaymentMethodData(
        id: json["id"].toString(),
        userId: json["user_id"].toString(),
        paymentMethodId: json["payment_method_id"].toString(),
        userData: json["user_data"] == null ? [] : List<UserPaymentMethodData>.from(json["user_data"]!.map((x) => UserPaymentMethodData.fromJson(x))),
        remark: json["remark"],
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
        paymentMethod: json["payment_method"] == null ? null : PaymentMethod.fromJson(json["payment_method"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "payment_method_id": paymentMethodId,
        "user_data": userData == null ? [] : List<dynamic>.from(userData!.map((x) => x.toJson())),
        "remark": remark,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "payment_method": paymentMethod?.toJson(),
      };
}

class PaymentMethod {
  String? id;
  String? name;
  String? slug;
  List<String>? supportedCurrency;
  String? status;
  String? formId;
  String? image;
  String? brandingColor;
  String? createdAt;
  String? updatedAt;

  PaymentMethod({
    this.id,
    this.name,
    this.slug,
    this.supportedCurrency,
    this.status,
    this.formId,
    this.image,
    this.brandingColor,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json["id"].toString(),
        name: json["name"].toString(),
        slug: json["slug"].toString(),
        supportedCurrency: json["supported_currency"] == null ? [] : List<String>.from(json["supported_currency"]!.map((x) => x)),
        status: json["status"].toString(),
        formId: json["form_id"].toString(),
        image: json["image"].toString(),
        brandingColor: json["branding_color"],
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
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
      };
}

class UserPaymentMethodData {
  String? name;
  String? type;
  String? value;

  UserPaymentMethodData({
    this.name,
    this.type,
    this.value,
  });

  factory UserPaymentMethodData.fromJson(Map<String, dynamic> json) => UserPaymentMethodData(
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
