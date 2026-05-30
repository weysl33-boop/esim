// To parse this JSON data, do
//
//     final depositHistoryResponseModel = depositHistoryResponseModelFromJson(jsonString);

import 'dart:convert';

import '../auth/login/login_response_model.dart';

DepositHistoryResponseModel depositHistoryResponseModelFromJson(String str) => DepositHistoryResponseModel.fromJson(json.decode(str));

String depositHistoryResponseModelToJson(DepositHistoryResponseModel data) => json.encode(data.toJson());

class DepositHistoryResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  DepositHistoryResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory DepositHistoryResponseModel.fromJson(Map<String, dynamic> json) => DepositHistoryResponseModel(
        remark: json["remark"].toString(),
        status: json["status"].toString(),
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
  Deposits? deposits;

  Data({
    this.deposits,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        deposits: json["deposits"] == null ? null : Deposits.fromJson(json["deposits"]),
      );

  Map<String, dynamic> toJson() => {
        "deposits": deposits?.toJson(),
      };
}

class Deposits {
  List<DepositHistoryListModel>? data;

  String? nextPageUrl;
  String? path;

  Deposits({
    this.data,
    this.nextPageUrl,
    this.path,
  });

  factory Deposits.fromJson(Map<String, dynamic> json) => Deposits(
        data: json["data"] == null ? [] : List<DepositHistoryListModel>.from(json["data"]!.map((x) => DepositHistoryListModel.fromJson(x))),
        nextPageUrl: json["next_page_url"].toString(),
        path: json["path"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
      };
}

class DepositHistoryListModel {
  int? id;
  String? userId;
  String? walletId;
  String? currencyId;
  String? methodCode;
  String? amount;
  String? methodCurrency;
  String? charge;
  String? rate;
  String? finalAmount;
  String? btcAmount;
  String? btcWallet;
  String? trx;
  String? paymentTry;
  String? status;
  String? fromApi;
  String? adminFeedback;
  String? createdAt;
  String? updatedAt;
  Gateway? gateway;
  Wallet? wallet;

  DepositHistoryListModel({
    this.id,
    this.userId,
    this.walletId,
    this.currencyId,
    this.methodCode,
    this.amount,
    this.methodCurrency,
    this.charge,
    this.rate,
    this.finalAmount,
    this.btcAmount,
    this.btcWallet,
    this.trx,
    this.paymentTry,
    this.status,
    this.fromApi,
    this.adminFeedback,
    this.createdAt,
    this.updatedAt,
    this.gateway,
    this.wallet,
  });

  factory DepositHistoryListModel.fromJson(Map<String, dynamic> json) => DepositHistoryListModel(
        id: json["id"],
        userId: json["user_id"].toString(),
        walletId: json["wallet_id"].toString(),
        currencyId: json["currency_id"].toString(),
        methodCode: json["method_code"].toString(),
        amount: json["amount"].toString(),
        methodCurrency: json["method_currency"].toString(),
        charge: json["charge"].toString(),
        rate: json["rate"].toString(),
        finalAmount: json["final_amount"].toString(),
        btcAmount: json["btc_amount"].toString(),
        btcWallet: json["btc_wallet"].toString(),
        trx: json["trx"].toString(),
        paymentTry: json["payment_try"].toString(),
        status: json["status"].toString(),
        fromApi: json["from_api"].toString(),
        adminFeedback: json["admin_feedback"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
        gateway: json["gateway"] == null ? null : Gateway.fromJson(json["gateway"]),
        wallet: json["wallet"] == null ? null : Wallet.fromJson(json["wallet"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "wallet_id": walletId,
        "currency_id": currencyId,
        "method_code": methodCode,
        "amount": amount,
        "method_currency": methodCurrency,
        "charge": charge,
        "rate": rate,
        "final_amount": finalAmount,
        "btc_amount": btcAmount,
        "btc_wallet": btcWallet,
        "trx": trx,
        "payment_try": paymentTry,
        "status": status,
        "from_api": fromApi,
        "admin_feedback": adminFeedback,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "gateway": gateway?.toJson(),
        "wallet": wallet?.toJson(),
      };
}

class Gateway {
  int? id;
  String? formId;
  String? code;
  String? name;
  String? alias;
  String? status;
  String? crypto;
  String? description;
  String? createdAt;
  String? updatedAt;

  Gateway({
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
  });

  factory Gateway.fromJson(Map<String, dynamic> json) => Gateway(
        id: json["id"],
        formId: json["form_id"].toString(),
        code: json["code"].toString(),
        name: json["name"].toString(),
        alias: json["alias"].toString(),
        status: json["status"].toString(),
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
        "description": description,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

class Wallet {
  int? id;
  String? userId;
  String? currencyId;
  String? balance;
  String? walletType;
  String? createdAt;
  String? updatedAt;

  Wallet({
    this.id,
    this.userId,
    this.currencyId,
    this.balance,
    this.walletType,
    this.createdAt,
    this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json["id"],
        userId: json["user_id"].toString(),
        currencyId: json["currency_id"].toString(),
        balance: json["balance"].toString(),
        walletType: json["wallet_type"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "currency_id": currencyId,
        "balance": balance,
        "wallet_type": walletType,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
