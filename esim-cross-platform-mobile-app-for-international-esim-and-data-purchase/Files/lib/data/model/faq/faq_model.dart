// To parse this JSON data, do
//
//     final faqsResponseModel = faqsResponseModelFromJson(jsonString);

import 'dart:convert';

import '../auth/login/login_response_model.dart';

FaqsResponseModel faqsResponseModelFromJson(String str) => FaqsResponseModel.fromJson(json.decode(str));

String faqsResponseModelToJson(FaqsResponseModel data) => json.encode(data.toJson());

class FaqsResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  FaqsResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory FaqsResponseModel.fromJson(Map<String, dynamic> json) => FaqsResponseModel(
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
  Faqs? faqs;

  Data({
    this.faqs,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        faqs: json["faq"] == null ? null : Faqs.fromJson(json["faq"]),
      );

  Map<String, dynamic> toJson() => {
        "faq": faqs?.toJson(),
      };
}

class Faqs {
  String? currentPage;
  List<FaqsDataModel>? data;
  String? firstPageUrl;
  String? path;
  String? nextPageUrl;

  String? total;

  Faqs({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.path,
    this.nextPageUrl,
    this.total,
  });

  factory Faqs.fromJson(Map<String, dynamic> json) => Faqs(
        currentPage: json["current_page"].toString(),
        data: json["data"] == null ? [] : List<FaqsDataModel>.from(json["data"]!.map((x) => FaqsDataModel.fromJson(x))),
        firstPageUrl: json["first_page_url"].toString(),
        nextPageUrl: json["next_page_url"].toString(),
        path: json["path"].toString(),
        total: json["total"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "next_page_url": nextPageUrl,
        "path": path,
        "total": total,
      };
}

class FaqsDataModel {
  String? id;
  String? dataKeys;
  DataValues? dataValues;
  String? tempname;
  String? createdAt;
  String? updatedAt;

  FaqsDataModel({
    this.id,
    this.dataKeys,
    this.dataValues,
    this.tempname,
    this.createdAt,
    this.updatedAt,
  });

  factory FaqsDataModel.fromJson(Map<String, dynamic> json) => FaqsDataModel(
        id: json["id"].toString(),
        dataKeys: json["data_keys"].toString(),
        dataValues: json["data_values"] == null ? null : DataValues.fromJson(json["data_values"]),
        tempname: json["tempname"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "data_keys": dataKeys,
        "data_values": dataValues?.toJson(),
        "tempname": tempname,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

class DataValues {
  String? question;
  String? answer;

  DataValues({
    this.question,
    this.answer,
  });

  factory DataValues.fromJson(Map<String, dynamic> json) => DataValues(
        question: json["question"].toString(),
        answer: json["answer"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "question": question,
        "answer": answer,
      };
}
