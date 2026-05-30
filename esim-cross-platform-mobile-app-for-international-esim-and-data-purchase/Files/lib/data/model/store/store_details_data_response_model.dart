// To parse this JSON data, do
//
//     final storeDataResponseModel = storeDataResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:esim/data/model/auth/login/login_response_model.dart';
import 'package:esim/data/model/dashboard/dashboard_response_model.dart';

StoreDetailsDataResponseModel storeDetailsDataResponseModelFromJson(String str) => StoreDetailsDataResponseModel.fromJson(json.decode(str));

String storeDetailsDataResponseModelToJson(StoreDetailsDataResponseModel data) => json.encode(data.toJson());

class StoreDetailsDataResponseModel {
  final String? remark;
  final String? status;
  final Message? message;
  final Data? data;

  StoreDetailsDataResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory StoreDetailsDataResponseModel.fromJson(Map<String, dynamic> json) => StoreDetailsDataResponseModel(
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
  final Country? country;
  final Plans? plans;
  final Campaign? campaign;
  final Region? region;

  Data({
    this.country,
    this.plans,
    this.campaign,
    this.region,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        country: json["country"] == null ? null : Country.fromJson(json["country"]),
        plans: json["plans"] == null ? null : Plans.fromJson(json["plans"]),
        campaign: json["campaign"] == null ? null : Campaign.fromJson(json["campaign"]),
        region: json["region"] == null ? null : Region.fromJson(json["region"]),
      );

  Map<String, dynamic> toJson() => {
        "country": country?.toJson(),
        "plans": plans?.toJson(),
        "campaign": campaign?.toJson(),
        "region": region?.toJson(),
      };
}

class Region {
  final String? id;
  final String? name;
  final String? slug;
  final String? regionImage;
  final String? banner;
  final String? imagePath;
  final String? bannerPath;

  Region({
    this.id,
    this.name,
    this.slug,
    this.regionImage,
    this.banner,
    this.imagePath,
    this.bannerPath,
  });

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        id: json["id"]?.toString(),
        name: json["name"]?.toString(),
        slug: json["slug"]?.toString(),
        regionImage: json["region_image"]?.toString(),
        banner: json["banner"]?.toString(),
        imagePath: json["image_path"]?.toString(),
        bannerPath: json["banner_path"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "region_image": regionImage,
        "banner": banner,
        "image_path": imagePath,
        "banner_path": bannerPath,
      };
}

class Country {
  final String? id;
  final String? name;
  final String? slug;
  final String? image;
  final String? imageSrc;
  final String? bannerPath;

  Country({
    this.id,
    this.name,
    this.slug,
    this.image,
    this.imageSrc,
    this.bannerPath,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json["id"]?.toString(),
        name: json["name"]?.toString(),
        slug: json["slug"]?.toString(),
        image: json["image"]?.toString(),
        imageSrc: json["image_path"]?.toString(),
        bannerPath: json["banner_path"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "image": image,
        "image_path": imageSrc,
        "banner_path": bannerPath,
      };
}

class Plans {
  final String? currentPage;
  final List<PlanData>? data;
  final String? firstPageUrl;
  final String? from;
  final String? lastPage;
  final String? lastPageUrl;
  final dynamic nextPageUrl;
  final String? path;
  final String? perPage;
  final dynamic prevPageUrl;
  final String? to;
  final String? total;

  Plans({
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

  factory Plans.fromJson(Map<String, dynamic> json) => Plans(
        currentPage: json["current_page"]?.toString(),
        data: json["data"] == null ? [] : List<PlanData>.from(json["data"]!.map((x) => PlanData.fromJson(x))),
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

class PlanData {
  final String? id;
  final String? uid;
  final String? name;
  final String? slug;
  final String? validity;
  final String? packageType;
  final String? dataVolume;
  final String? dataUnit;
  final String? voiceQuantity;
  final String? voiceUnit;
  final String? smsQuantity;
  final String? period;
  final String? periodUnit;
  final String? price;
  final String? currency;
  final String? reloadable;
  final String? refundable;
  final String? phoneNumber;
  final String? operatorName;
  final String? networkSpeed;
  final String? areaCoverage;
  final Campaign? campaign;

  PlanData({
    this.id,
    this.uid,
    this.name,
    this.validity,
    this.slug,
    this.packageType,
    this.dataVolume,
    this.dataUnit,
    this.voiceQuantity,
    this.voiceUnit,
    this.smsQuantity,
    this.period,
    this.periodUnit,
    this.price,
    this.currency,
    this.reloadable,
    this.refundable,
    this.phoneNumber,
    this.operatorName,
    this.networkSpeed,
    this.areaCoverage,
    this.campaign,
  });

  factory PlanData.fromJson(Map<String, dynamic> json) => PlanData(
        id: json["id"]?.toString(),
        uid: json["uid"]?.toString(),
        name: json["name"]?.toString(),
        validity: json["validity"]?.toString(),
        slug: json["slug"]?.toString(),
        packageType: json["package_type"]?.toString(),
        dataVolume: json["data_volume"]?.toString(),
        dataUnit: json["data_unit"]?.toString(),
        voiceQuantity: json["voice_quantity"]?.toString(),
        voiceUnit: json["voice_unit"]?.toString(),
        smsQuantity: json["sms_quantity"]?.toString(),
        period: json["period"]?.toString(),
        periodUnit: json["period_unit"]?.toString(),
        price: json["price"]?.toString(),
        currency: json["currency"]?.toString(),
        reloadable: json["reloadable"]?.toString(),
        refundable: json["refundable"]?.toString(),
        phoneNumber: json["phone_number"]?.toString(),
        operatorName: json["operator_name"]?.toString(),
        networkSpeed: json["network_speed"]?.toString(),
        areaCoverage: json["area_coverage"]?.toString(),
        campaign: json["campaign"] == null ? null : Campaign.fromJson(json["campaign"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uid": uid,
        "name": name,
        "slug": slug,
        "package_type": packageType,
        "validity": validity,
        "data_volume": dataVolume,
        "data_unit": dataUnit,
        "voice_quantity": voiceQuantity,
        "voice_unit": voiceUnit,
        "sms_quantity": smsQuantity,
        "period": period,
        "period_unit": periodUnit,
        "price": price,
        "currency": currency,
        "reloadable": reloadable,
        "refundable": refundable,
        "phone_number": phoneNumber,
        "operator_name": operatorName,
        "network_speed": networkSpeed,
        "area_coverage": areaCoverage,
        "campaign": campaign?.toJson(),
      };
}
