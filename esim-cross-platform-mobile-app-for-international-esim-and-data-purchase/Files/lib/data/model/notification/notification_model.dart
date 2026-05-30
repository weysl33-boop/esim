// To parse this JSON data, do
//
//     final notificationResponseModel = notificationResponseModelFromJson(jsonString);

import 'dart:convert';

import '../auth/login/login_response_model.dart';

NotificationResponseModel notificationResponseModelFromJson(String str) => NotificationResponseModel.fromJson(json.decode(str));

String notificationResponseModelToJson(NotificationResponseModel data) => json.encode(data.toJson());

class NotificationResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  NotificationResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) => NotificationResponseModel(
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
  Notifications? notifications;

  Data({
    this.notifications,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        notifications: json["notifications"] == null ? null : Notifications.fromJson(json["notifications"]),
      );

  Map<String, dynamic> toJson() => {
        "notifications": notifications?.toJson(),
      };
}

class Notifications {
  List<NotificationsData>? data;

  String? path;
  String? nextPageUrl;

  Notifications({
    this.data,
    this.nextPageUrl,
    this.path,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) => Notifications(
        data: json["data"] == null ? [] : List<NotificationsData>.from(json["data"]!.map((x) => NotificationsData.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
      };
}

class NotificationsData {
  String? id;
  String? userId;
  String? sender;
  String? sentFrom;
  String? sentTo;
  String? subject;
  String? message;
  String? notificationType;
  String? createdAt;
  String? updatedAt;

  NotificationsData({
    this.id,
    this.userId,
    this.sender,
    this.sentFrom,
    this.sentTo,
    this.subject,
    this.message,
    this.notificationType,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationsData.fromJson(Map<String, dynamic> json) => NotificationsData(
        id: json["id"].toString(),
        userId: json["user_id"].toString(),
        sender: json["sender"].toString(),
        sentFrom: json["sent_from"].toString(),
        sentTo: json["sent_to"].toString(),
        subject: json["subject"].toString(),
        message: json["message"].toString(),
        notificationType: json["notification_type"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "sender": sender,
        "sent_from": sentFrom,
        "sent_to": sentTo,
        "subject": subject,
        "message": message,
        "notification_type": notificationType,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
