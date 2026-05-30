import 'dart:convert';

import 'package:esim/data/model/auth/login/login_response_model.dart';

RefferalScreenResponseModel referralScreenResponseModelFromJson(String str) => RefferalScreenResponseModel.fromJson(json.decode(str));

String referralScreenResponseModelToJson(RefferalScreenResponseModel data) => json.encode(data.toJson());

class RefferalScreenResponseModel {
  final String? remark;
  final String? status;
  final Message? message;
  final Data? data;

  RefferalScreenResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory RefferalScreenResponseModel.fromJson(Map<String, dynamic> json) => RefferalScreenResponseModel(
        remark: json["remark"]?.toString(),
        status: json["status"]?.toString(),
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
  final Referrals? referrals;
  final String? totalReferrals;
  final String? totalEarning;

  Data({
    this.referrals,
    this.totalReferrals,
    this.totalEarning,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        referrals: json["referrals"] == null ? null : Referrals.fromJson(json["referrals"]),
        totalReferrals: json["total_referrals"]?.toString(),
        totalEarning: json["total_earning"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "referrals": referrals?.toJson(),
        "total_referrals": totalReferrals,
        "total_earning": totalEarning,
      };
}

class Referrals {
  final String? currentPage;
  final List<AllReferral>? data;
  final String? firstPageUrl;
  final String? from;
  final String? lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String? path;
  final String? perPage;
  final String? prevPageUrl;
  final String? to;
  final String? total;

  Referrals({
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

  factory Referrals.fromJson(Map<String, dynamic> json) => Referrals(
        currentPage: json["current_page"]?.toString(),
        data: json["data"] == null ? <AllReferral>[] : List<AllReferral>.from(json["data"].map((x) => AllReferral.fromJson(x))),
        firstPageUrl: json["first_page_url"]?.toString(),
        from: json["from"]?.toString(),
        lastPage: json["last_page"]?.toString(),
        lastPageUrl: json["last_page_url"]?.toString(),
        nextPageUrl: json["next_page_url"]?.toString(),
        path: json["path"]?.toString(),
        perPage: json["per_page"]?.toString(),
        prevPageUrl: json["prev_page_url"]?.toString(),
        to: json["to"]?.toString(),
        total: json["total"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": data == null ? <dynamic>[] : List<dynamic>.from(data!.map((x) => x.toJson())),
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

class AllReferral {
  final String? id;
  final String? firstname;
  final String? lastname;
  final String? username;
  final String? email;
  final String? mobile;
  final String? createdAt;
  final String? image;
  final List<AllReferral>? allReferrals;

  AllReferral({
    this.id,
    this.firstname,
    this.lastname,
    this.username,
    this.email,
    this.mobile,
    this.createdAt,
    this.image,
    this.allReferrals,
  });

  factory AllReferral.fromJson(Map<String, dynamic> json) => AllReferral(
        id: json["id"]?.toString(),
        firstname: (json["firstname"] ?? "").toString(),
        lastname: (json["lastname"] ?? "").toString(),
        username: (json["username"] ?? "").toString(),
        email: (json["email"] ?? "").toString(),
        mobile: (json["mobile"] ?? "").toString(),
        createdAt: json["created_at"]?.toString(),
        image: (json["image"] ?? "").toString(),
        allReferrals: json["all_referrals"] == null ? <AllReferral>[] : List<AllReferral>.from(json["all_referrals"].map((x) => AllReferral.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstname": firstname,
        "lastname": lastname,
        "username": username,
        "email": email,
        "mobile": mobile,
        "created_at": createdAt,
        "image": image,
        "all_referrals": allReferrals == null ? <dynamic>[] : List<dynamic>.from(allReferrals!.map((x) => x.toJson())),
      };

  String getFullName() {
    final first = firstname?.trim() ?? "";
    final last = lastname?.trim() ?? "";
    return "$first $last".trim();
  }
}
