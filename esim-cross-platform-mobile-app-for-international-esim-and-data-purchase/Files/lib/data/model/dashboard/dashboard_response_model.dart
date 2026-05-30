// To parse this JSON data, do
//
//     final homeDataResponseModel = homeDataResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:esim/data/model/my_esim/active_esim_response_model.dart';
import 'package:esim/data/model/user/user_model.dart';

import '../auth/login/login_response_model.dart';

HomeDataResponseModel homeDataResponseModelFromJson(String str) => HomeDataResponseModel.fromJson(json.decode(str));

String homeDataResponseModelToJson(HomeDataResponseModel data) => json.encode(data.toJson());

class HomeDataResponseModel {
  final String? remark;
  final String? status;
  final Message? message;
  final Data? data;

  HomeDataResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory HomeDataResponseModel.fromJson(Map<String, dynamic> json) => HomeDataResponseModel(
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
  final List<PopularCountry>? popularCountries;
  final List<Campaign>? campaigns;
  final String? campaginBannerUrl;
  final User? user;

  Data({
    this.popularCountries,
    this.campaigns,
    this.campaginBannerUrl,
    this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        popularCountries: json["popular_countries"] == null ? [] : List<PopularCountry>.from(json["popular_countries"]!.map((x) => PopularCountry.fromJson(x))),
        campaigns: json["campaigns"] == null ? [] : List<Campaign>.from(json["campaigns"]!.map((x) => Campaign.fromJson(x))),
        campaginBannerUrl: json["campagin_banner_url"],
        user: json["user"],
      );

  Map<String, dynamic> toJson() => {
        "popular_countries": popularCountries == null ? [] : List<dynamic>.from(popularCountries!.map((x) => x.toJson())),
        "campaigns": campaigns == null ? [] : List<dynamic>.from(campaigns!.map((x) => x.toJson())),
        "campagin_banner_url": campaginBannerUrl,
        "user": user,
      };
}

class Campaign {
  final String? id;
  final String? title;
  final String? banner;
  final String? discount;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final List<Plan>? plans;
  final String? bannerPath;

  Campaign({this.id, this.title, this.banner, this.discount, this.status, this.createdAt, this.updatedAt, this.plans, this.bannerPath});

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
        id: json["id"]?.toString(),
        title: json["title"]?.toString(),
        banner: json["banner"]?.toString(),
        discount: json["discount"]?.toString(),
        status: json["status"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
        bannerPath: json["banner_path"]?.toString(),
        plans: json["plans"] == null ? [] : List<Plan>.from(json["plans"]!.map((x) => Plan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "banner": banner,
        "discount": discount,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "banner_path": bannerPath,
        "plans": plans == null ? [] : List<dynamic>.from(plans!.map((x) => x.toJson())),
      };
}

class PopularCountry {
  final String? id;
  final String? name;
  final String? image;
  final String? imageSrc;

  PopularCountry({
    this.id,
    this.name,
    this.image,
    this.imageSrc,
  });

  factory PopularCountry.fromJson(Map<String, dynamic> json) => PopularCountry(
        id: json["id"]?.toString(),
        name: json["name"]?.toString(),
        image: json["image"]?.toString(),
        imageSrc: json["image_src"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "image_src": imageSrc,
      };
}
