// To parse this JSON data, do
//
//     final topUpSelectedPlanResponseModel = topUpSelectedPlanResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:esim/data/model/auth/login/login_response_model.dart';

TopUpSelectedPlanResponseModel topUpSelectedPlanResponseModelFromJson(String str) => TopUpSelectedPlanResponseModel.fromJson(json.decode(str));

String topUpSelectedPlanResponseModelToJson(TopUpSelectedPlanResponseModel data) => json.encode(data.toJson());

class TopUpSelectedPlanResponseModel {
  final String? remark;
  final String? status;
  final Message? message;
  final Data? data;

  TopUpSelectedPlanResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory TopUpSelectedPlanResponseModel.fromJson(Map<String, dynamic> json) => TopUpSelectedPlanResponseModel(
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
  final Topup? topup;

  Data({
    this.topup,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        topup: json["topup"] == null ? null : Topup.fromJson(json["topup"]),
      );

  Map<String, dynamic> toJson() => {
        "topup": topup?.toJson(),
      };
}

class Topup {
  final String? id;
  final String? name;
  final String? dataVolume;
  final String? voiceQuantity;
  final String? smsQuantity;
  final String? validity;
  final String? price;
  final String? status;
  final String? createdAt;

  Topup({
    this.id,
    this.name,
    this.dataVolume,
    this.voiceQuantity,
    this.smsQuantity,
    this.validity,
    this.price,
    this.status,
    this.createdAt,
  });

  factory Topup.fromJson(Map<String, dynamic> json) => Topup(
        id: json["id"]?.toString(),
        name: json["name"]?.toString(),
        dataVolume: json["data_volume"]?.toString(),
        voiceQuantity: json["voice_quantity"]?.toString(),
        smsQuantity: json["sms_quantity"]?.toString(),
        validity: json["validity"]?.toString(),
        price: json["price"]?.toString(),
        status: json["status"]?.toString(),
        createdAt: json["created_at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "data_volume": dataVolume,
        "voice_quantity": voiceQuantity,
        "sms_quantity": smsQuantity,
        "validity": validity,
        "price": price,
        "status": status,
        "created_at": createdAt,
      };
}
