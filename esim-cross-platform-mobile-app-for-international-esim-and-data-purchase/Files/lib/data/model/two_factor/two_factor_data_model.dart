// To parse this JSON data, do
//
//     final twoFactorCodeModel = twoFactorCodeModelFromJson(jsonString);

import 'dart:convert';

import '../auth/sign_up_model/registration_response_model.dart';

TwoFactorCodeModel twoFactorCodeModelFromJson(String str) => TwoFactorCodeModel.fromJson(json.decode(str));

String twoFactorCodeModelToJson(TwoFactorCodeModel data) => json.encode(data.toJson());

class TwoFactorCodeModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  TwoFactorCodeModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory TwoFactorCodeModel.fromJson(Map<String, dynamic> json) => TwoFactorCodeModel(
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
  String? qrCodeUrl;
  String? secret;

  Data({
    this.qrCodeUrl,
    this.secret,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        qrCodeUrl: json["qr_code_url"].toString(),
        secret: json["secret"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "qr_code_url": qrCodeUrl,
        "secret": secret,
      };
}
