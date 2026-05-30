import 'dart:convert';

import '../auth/login/login_response_model.dart';
import 'wallet_list_model.dart';

SingleWalletDetailsModel singleWalletDetailsModelFromJson(String str) => SingleWalletDetailsModel.fromJson(json.decode(str));

String singleWalletDetailsModelToJson(SingleWalletDetailsModel data) => json.encode(data.toJson());

class SingleWalletDetailsModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  SingleWalletDetailsModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory SingleWalletDetailsModel.fromJson(Map<String, dynamic> json) => SingleWalletDetailsModel(
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
  WalletData? wallet;
  SingleWalletWidgetCounter? widget;
  WalletTransactionsModel? transactions;
  Currency? currency;
  String? walletType;

  Data({
    this.wallet,
    this.widget,
    this.transactions,
    this.currency,
    this.walletType,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      wallet: json["wallet"] == null ? null : WalletData.fromJson(json["wallet"]),
      widget: json["widget"] == null ? null : SingleWalletWidgetCounter.fromJson(json["widget"]),
      transactions: json["transactions"] == null ? null : WalletTransactionsModel.fromJson(json["transactions"]),
      currency: json["currency"] == null ? null : Currency.fromJson(json["currency"]),
      walletType: json["wallet_type"].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "wallet": wallet?.toJson(),
        "widget": widget?.toJson(),
        "transactions": transactions?.toJson(),
        "currency": currency?.toJson(),
        "wallet_type": walletType,
      };
}

class Currency {
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

  Currency({
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

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
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

class WalletTransactionsModel {
  String? currentPage;
  List<TransactionSingleData>? data;
  String? firstPageUrl;
  String? from;
  String? lastPage;
  String? lastPageUrl;
  String? nextPageUrl;
  String? path;
  String? perPage;
  String? prevPageUrl;
  String? to;
  String? total;

  WalletTransactionsModel({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory WalletTransactionsModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionsModel(
      currentPage: json["current_page"].toString(),
      data: json["data"] == null ? [] : List<TransactionSingleData>.from(json["data"]!.map((x) => TransactionSingleData.fromJson(x))),
      lastPageUrl: json["last_page_url"].toString(),
      nextPageUrl: json["next_page_url"].toString(),
      total: json["total"].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class TransactionSingleData {
  int? id;
  String? userId;
  String? amount;
  String? charge;
  String? postBalance;
  String? trxType;
  String? trx;
  String? details;
  String? remark;
  String? walletId;
  String? createdAt;
  String? updatedAt;
  WalletData? wallet;

  TransactionSingleData({
    this.id,
    this.userId,
    this.amount,
    this.charge,
    this.postBalance,
    this.trxType,
    this.trx,
    this.details,
    this.remark,
    this.walletId,
    this.createdAt,
    this.updatedAt,
    this.wallet,
  });

  factory TransactionSingleData.fromJson(Map<String, dynamic> json) => TransactionSingleData(
        id: json["id"],
        userId: json["user_id"].toString(),
        amount: json["amount"].toString(),
        charge: json["charge"].toString(),
        postBalance: json["post_balance"].toString(),
        trxType: json["trx_type"].toString(),
        trx: json["trx"].toString(),
        details: json["details"].toString(),
        remark: json["remark"].toString(),
        walletId: json["wallet_id"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
        wallet: json["wallet"] == null ? null : WalletData.fromJson(json["wallet"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "amount": amount,
        "charge": charge,
        "post_balance": postBalance,
        "trx_type": trxType,
        "trx": trx,
        "details": details,
        "remark": remark,
        "wallet_id": walletId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "wallet": wallet?.toJson(),
      };
}

class SingleWalletWidgetCounter {
  String? totalOrder;
  String? openOrder;
  String? completedOrder;
  String? canceledOrder;
  String? totalDeposit;
  String? totalWithdraw;
  String? totalTransaction;
  String? totalTrade;

  SingleWalletWidgetCounter({
    this.totalOrder,
    this.openOrder,
    this.completedOrder,
    this.canceledOrder,
    this.totalDeposit,
    this.totalWithdraw,
    this.totalTransaction,
    this.totalTrade,
  });

  factory SingleWalletWidgetCounter.fromJson(Map<String, dynamic> json) => SingleWalletWidgetCounter(
        totalOrder: json["total_order"].toString(),
        openOrder: json["open_order"].toString(),
        completedOrder: json["completed_order"].toString(),
        canceledOrder: json["canceled_order"].toString(),
        totalDeposit: json["total_deposit"].toString(),
        totalWithdraw: json["total_withdraw"].toString(),
        totalTransaction: json["total_transaction"].toString(),
        totalTrade: json["total_trade"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "total_order": totalOrder,
        "open_order": openOrder,
        "completed_order": completedOrder,
        "canceled_order": canceledOrder,
        "total_deposit": totalDeposit,
        "total_withdraw": totalWithdraw,
        "total_transaction": totalTransaction,
        "total_trade": totalTrade,
      };
}
