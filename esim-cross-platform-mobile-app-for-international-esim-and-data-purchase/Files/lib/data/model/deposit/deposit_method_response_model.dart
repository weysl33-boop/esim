// To parse this JSON data, do
//
//     final depositMethodResponseModel = depositMethodResponseModelFromJson(jsonString);

import 'dart:convert';

import '../auth/login/login_response_model.dart';

DepositMethodResponseModel depositMethodResponseModelFromJson(String str) => DepositMethodResponseModel.fromJson(json.decode(str));

String depositMethodResponseModelToJson(DepositMethodResponseModel data) => json.encode(data.toJson());

class DepositMethodResponseModel {
  String? remark;
  Message? message;
  Data? data;

  DepositMethodResponseModel({
    this.remark,
    this.message,
    this.data,
  });

  factory DepositMethodResponseModel.fromJson(Map<String, dynamic> json) => DepositMethodResponseModel(
        remark: json["remark"],
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "remark": remark,
        "message": message?.toJson(),
        "data": data?.toJson(),
      };
}

class Data {
  List<DepositMethod>? methods;
  final String? imagePath;

  Data({
    this.methods,
    this.imagePath,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        methods: json["methods"] == null ? [] : List<DepositMethod>.from(json["methods"]!.map((x) => DepositMethod.fromJson(x))),
        imagePath: json["image_path"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "methods": methods == null ? [] : List<dynamic>.from(methods!.map((x) => x.toJson())),
        "image_path": imagePath,
      };
}

class DepositCurrency {
  String? id;
  String? type;
  String? name;
  String? sign;
  String? symbol;
  String? image;
  String? rate;
  String? rank;
  String? status;
  String? highlightedCoin;
  String? p2PSn;
  String? createdAt;
  String? updatedAt;
  String? imageUrl;

  DepositCurrency({
    this.id,
    this.type,
    this.name,
    this.sign,
    this.symbol,
    this.image,
    this.rate,
    this.rank,
    this.status,
    this.highlightedCoin,
    this.p2PSn,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
  });

  factory DepositCurrency.fromJson(Map<String, dynamic> json) => DepositCurrency(
        id: json["id"].toString(),
        type: json["type"].toString(),
        name: json["name"].toString(),
        sign: json["sign"].toString(),
        symbol: json["symbol"].toString(),
        image: json["image"].toString(),
        rate: json["rate"].toString(),
        rank: json["rank"].toString(),
        status: json["status"].toString(),
        highlightedCoin: json["highlighted_coin"].toString(),
        p2PSn: json["p2p_sn"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
        imageUrl: json["image_url"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "name": name,
        "sign": sign,
        "symbol": symbol,
        "image": image,
        "rate": rate,
        "rank": rank,
        "status": status,
        "highlighted_coin": highlightedCoin,
        "p2p_sn": p2PSn,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "image_url": imageUrl,
      };
}

class DepositMethod {
  int? id;
  String? name;
  String? currency;
  String? symbol;
  String? methodCode;
  String? gatewayAlias;
  String? minAmount;
  String? maxAmount;
  String? percentCharge;
  String? fixedCharge;
  String? rate;
  String? image;
  String? createdAt;
  String? updatedAt;
  MethodMethod? method;

  DepositMethod({
    this.id,
    this.name,
    this.currency,
    this.symbol,
    this.methodCode,
    this.gatewayAlias,
    this.minAmount,
    this.maxAmount,
    this.percentCharge,
    this.fixedCharge,
    this.rate,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.method,
  });

  factory DepositMethod.fromJson(Map<String, dynamic> json) => DepositMethod(
        id: json["id"],
        name: json["name"].toString(),
        currency: json["currency"].toString(),
        symbol: json["symbol"].toString(),
        methodCode: json["method_code"].toString(),
        gatewayAlias: json["gateway_alias"].toString(),
        minAmount: json["min_amount"].toString(),
        maxAmount: json["max_amount"].toString(),
        percentCharge: json["percent_charge"].toString(),
        fixedCharge: json["fixed_charge"].toString(),
        rate: json["rate"].toString(),
        image: json["image"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
        method: json["method"] == null ? null : MethodMethod.fromJson(json["method"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "currency": currency,
        "symbol": symbol,
        "method_code": methodCode,
        "gateway_alias": gatewayAlias,
        "min_amount": minAmount,
        "max_amount": maxAmount,
        "percent_charge": percentCharge,
        "fixed_charge": fixedCharge,
        "rate": rate,
        "image": image,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "method": method?.toJson(),
      };
}

class MethodMethod {
  int? id;
  String? formId;
  String? code;
  String? name;
  String? alias;
  String? status;
  String? image;
  String? crypto;
  dynamic description;
  String? createdAt;
  String? updatedAt;

  MethodMethod({
    this.id,
    this.formId,
    this.code,
    this.name,
    this.alias,
    this.status,
    this.crypto,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.image,
  });

  factory MethodMethod.fromJson(Map<String, dynamic> json) => MethodMethod(
        id: json["id"],
        formId: json["form_id"].toString(),
        code: json["code"].toString(),
        name: json["name"].toString(),
        alias: json["alias"].toString(),
        status: json["status"].toString(),
        image: json["image"].toString(),
        crypto: json["crypto"].toString(),
        description: json["description"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "form_id": formId,
        "code": code,
        "name": name,
        "alias": alias,
        "status": status,
        "crypto": crypto,
        "image": image,
        "description": description,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
