import 'dart:convert';

import 'package:esim/data/model/auth/login/login_response_model.dart';

StoreDataResponseModel storeDataResponseModelFromJson(String str) => StoreDataResponseModel.fromJson(json.decode(str));

String storeDataResponseModelToJson(StoreDataResponseModel data) => json.encode(data.toJson());

class StoreDataResponseModel {
  final String? remark;
  final String? status;
  final Message? message;
  final Data? data;

  StoreDataResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory StoreDataResponseModel.fromJson(Map<String, dynamic> json) => StoreDataResponseModel(
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
  final Countries? countries;
  final Countries? regions;
  final String? totalGlobalPlans;

  Data({
    this.countries,
    this.regions,
    this.totalGlobalPlans,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        countries: json["countries"] == null ? null : Countries.fromJson(json["countries"]),
        regions: json["regions"] == null ? null : Countries.fromJson(json["regions"]),
        totalGlobalPlans: json["total_global_plans"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "countries": countries?.toJson(),
        "regions": regions?.toJson(),
        "total_global_plans": totalGlobalPlans,
      };
}

class Countries {
  final String? currentPage;
  final List<Datum>? data;
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

  Countries({
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

  factory Countries.fromJson(Map<String, dynamic> json) => Countries(
        currentPage: json["current_page"]?.toString(),
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
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

class Datum {
  final String? id;
  final String? code;
  final String? name;
  final String? slug;
  final String? image;
  final String? isFeatured;
  final String? dataplansioUid;
  final String? esimsmUid;
  final String? esimaccessUid;
  final String? esimcardUid;
  final String? airaloUid;
  final String? status;
  final String? regionImage;
  final String? createdAt;
  final String? updatedAt;
  final String? startsFrom;
  final String? totalPlans;

  Datum({
    this.id,
    this.code,
    this.name,
    this.slug,
    this.image,
    this.isFeatured,
    this.dataplansioUid,
    this.esimsmUid,
    this.esimaccessUid,
    this.esimcardUid,
    this.airaloUid,
    this.status,
    this.regionImage,
    this.createdAt,
    this.updatedAt,
    this.startsFrom,
    this.totalPlans,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"]?.toString(),
        code: json["code"]?.toString(),
        name: json["name"]?.toString(),
        slug: json["slug"]?.toString(),
        image: json["image"]?.toString(),
        isFeatured: json["is_featured"]?.toString(),
        dataplansioUid: json["dataplansio_uid"]?.toString(),
        esimsmUid: json["esimsm_uid"]?.toString(),
        esimaccessUid: json["esimaccess_uid"]?.toString(),
        esimcardUid: json["esimcard_uid"]?.toString(),
        airaloUid: json["airalo_uid"]?.toString(),
        status: json["status"]?.toString(),
        regionImage: json["region_image"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
        startsFrom: json["starts_from"]?.toString(),
        totalPlans: json["total_plan"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "name": name,
        "slug": slug,
        "image": image,
        "is_featured": isFeatured,
        "dataplansio_uid": dataplansioUid,
        "esimsm_uid": esimsmUid,
        "esimaccess_uid": esimaccessUid,
        "esimcard_uid": esimcardUid,
        "airalo_uid": airaloUid,
        "status": status,
        "region_image": regionImage,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "starts_from": startsFrom,
        "total_plan": totalPlans,
      };
}
