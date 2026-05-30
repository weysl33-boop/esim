import 'dart:convert';

import '../auth/login/login_response_model.dart';

WalletListModel walletListModelFromJson(String str) => WalletListModel.fromJson(json.decode(str));

String walletListModelToJson(WalletListModel data) => json.encode(data.toJson());

class WalletListModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  WalletListModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory WalletListModel.fromJson(Map<String, dynamic> json) => WalletListModel(
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
  Wallets? wallets;
  String? estimatedBalance;
  Data({
    this.wallets,
    this.estimatedBalance,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        wallets: json["wallets"] == null ? null : Wallets.fromJson(json["wallets"]),
        estimatedBalance: json["estimatedBalance"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "wallets": wallets?.toJson(),
        "estimatedBalance": estimatedBalance,
      };
}

class Wallets {
  String? currentPage;
  List<WalletData>? data;
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

  Wallets({
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

  factory Wallets.fromJson(Map<String, dynamic> json) => Wallets(
        currentPage: json["current_page"].toString(),
        data: json["data"] == null ? [] : List<WalletData>.from(json["data"]!.map((x) => WalletData.fromJson(x))),
        firstPageUrl: json["first_page_url"].toString().toString(),
        from: json["from"].toString(),
        lastPage: json["last_page"].toString(),
        lastPageUrl: json["last_page_url"].toString(),
        nextPageUrl: json["next_page_url"].toString(),
        path: json["path"].toString(),
        perPage: json["per_page"].toString(),
        prevPageUrl: json["prev_page_url"].toString(),
        to: json["to"].toString(),
        total: json["total"].toString(),
      );

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

class WalletData {
  String? id;
  String? userId;
  String? currencyId;
  String? balance;
  String? walletType;
  String? createdAt;
  String? updatedAt;
  String? inOrder;
  WalletCurrency? currency;

  WalletData({
    this.id,
    this.userId,
    this.currencyId,
    this.balance,
    this.walletType,
    this.createdAt,
    this.updatedAt,
    this.inOrder,
    this.currency,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) => WalletData(
        id: json["id"].toString(),
        userId: json["user_id"].toString(),
        currencyId: json["currency_id"].toString(),
        balance: json["balance"].toString(),
        walletType: json["wallet_type"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
        inOrder: json["in_order"].toString(),
        currency: json["currency"] == null ? null : WalletCurrency.fromJson(json["currency"]),
      );

  String totalBalance() {
    try {
      return (double.parse(inOrder ?? '0') + double.parse(balance ?? '0')).toString();
    } catch (e) {
      return '0';
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "currency_id": currencyId,
        "balance": balance,
        "wallet_type": walletType,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "in_order": inOrder,
        "currency": currency?.toJson(),
      };
}

class WalletCurrency {
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

  WalletCurrency({
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

  factory WalletCurrency.fromJson(Map<String, dynamic> json) => WalletCurrency(
        id: json["id"].toString(),
        type: json["type"].toString(),
        name: json["name"].toString(),
        sign: json["sign"] == null ? "" : json["sign"].toString(),
        symbol: json["symbol"] == null ? "" : json["symbol"].toString(),
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
