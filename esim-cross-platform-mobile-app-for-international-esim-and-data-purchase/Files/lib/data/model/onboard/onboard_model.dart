// To parse this JSON data, do
//
//     final onBoards = onBoardsFromJson(jsonString);

import 'dart:convert';

import '../auth/login/login_response_model.dart';

OnBoardResponseModel onBoardsFromJson(String str) => OnBoardResponseModel.fromJson(json.decode(str));

String onBoardsToJson(OnBoardResponseModel data) => json.encode(data.toJson());

class OnBoardResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  OnBoardResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory OnBoardResponseModel.fromJson(Map<String, dynamic> json) => OnBoardResponseModel(
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
  List<OnBoard>? onBoards;
  String? imagePath;

  Data({
    this.onBoards,
    this.imagePath,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        imagePath: json["path"],
      );

  Map<String, dynamic> toJson() => {
        "path": imagePath,
      };
}

class OnBoard {
  String? id;
  String? title;
  String? value;
  String? image;

  OnBoard({this.id, this.title, this.value, this.image});
}

class DataValues {
  String? title;
  String? subtitle;
  String? hasImage;
  String? image;

  DataValues({
    this.title,
    this.subtitle,
    this.hasImage,
    this.image,
  });

  factory DataValues.fromJson(Map<String, dynamic> json) => DataValues(
        title: json["title"].toString(),
        subtitle: json["subtitle"].toString(),
        hasImage: json["has_image"].toString(),
        image: json["image"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "subtitle": subtitle,
        "has_image": hasImage,
        "image": image,
      };
}
