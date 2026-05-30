// To parse this JSON data, do
//
//     final topUpPlansResponseModel = topUpPlansResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:esim/data/model/auth/login/login_response_model.dart';

TopUpPlansResponseModel topUpPlansResponseModelFromJson(String str) => TopUpPlansResponseModel.fromJson(json.decode(str));

String topUpPlansResponseModelToJson(TopUpPlansResponseModel data) => json.encode(data.toJson());

class TopUpPlansResponseModel {
  final String? remark;
  final String? status;
  final Message? message;
  final Data? data;

  TopUpPlansResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory TopUpPlansResponseModel.fromJson(Map<String, dynamic> json) => TopUpPlansResponseModel(
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
  final List<Plan>? plans;

  Data({
    this.plans,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        plans: json["plans"] == null ? [] : List<Plan>.from(json["plans"]!.map((x) => Plan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "plans": plans == null ? [] : List<dynamic>.from(plans!.map((x) => x.toJson())),
      };
}

class Plan {
  final String? uid;
  final String? price;
  final String? dataVolume;
  final String? voiceQuantity;
  final String? smsQuantity;
  final String? currency;
  final String? validity;
  final String? name;

  Plan({
    this.uid,
    this.price,
    this.dataVolume,
    this.voiceQuantity,
    this.smsQuantity,
    this.currency,
    this.validity,
    this.name,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        uid: json["uid"]?.toString(),
        price: json["price"]?.toString(),
        dataVolume: json["data_volume"]?.toString(),
        voiceQuantity: json["voice_quantity"]?.toString(),
        smsQuantity: json["sms_quantity"]?.toString(),
        currency: json["currency"]?.toString(),
        validity: json["validity"]?.toString(),
        name: json["name"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "price": price,
        "data_volume": dataVolume,
        "voice_quantity": voiceQuantity,
        "sms_quantity": smsQuantity,
        "currency": currency,
        "validity": validity,
        "name": name,
      };
}
