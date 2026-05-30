// To parse this JSON data, do
//
//     final planPurchaseResponseModel = planPurchaseResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:esim/data/model/auth/login/login_response_model.dart';

PlanPurchaseResponseModel planPurchaseResponseModelFromJson(String str) => PlanPurchaseResponseModel.fromJson(json.decode(str));

String planPurchaseResponseModelToJson(PlanPurchaseResponseModel data) => json.encode(data.toJson());

class PlanPurchaseResponseModel {
  final String? remark;
  final String? status;
  final Message? message;
  final Data? data;

  PlanPurchaseResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory PlanPurchaseResponseModel.fromJson(Map<String, dynamic> json) => PlanPurchaseResponseModel(
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
  final Order? order;

  Data({
    this.order,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        order: json["order"] == null ? null : Order.fromJson(json["order"]),
      );

  Map<String, dynamic> toJson() => {
        "order": order?.toJson(),
      };
}

class Order {
  final String? id;
  final String? userId;
  final String? totalAmount;
  final String? status;
  final String? createdAt;
  final OrderItem? orderItem;

  Order({
    this.id,
    this.userId,
    this.totalAmount,
    this.status,
    this.createdAt,
    this.orderItem,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"]?.toString(),
        userId: json["user_id"]?.toString(),
        totalAmount: json["total_amount"]?.toString(),
        status: json["status"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        orderItem: json["order_item"] == null ? null : OrderItem.fromJson(json["order_item"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "total_amount": totalAmount,
        "status": status,
        "created_at": createdAt,
        "order_item": orderItem?.toJson(),
      };
}

class OrderItem {
  final String? id;
  final String? orderId;
  final String? planId;
  final String? price;
  final String? isEsimCreated;
  final String? createdAt;

  OrderItem({
    this.id,
    this.orderId,
    this.planId,
    this.price,
    this.isEsimCreated,
    this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json["id"]?.toString(),
        orderId: json["order_id"]?.toString(),
        planId: json["plan_id"]?.toString(),
        price: json["price"]?.toString(),
        isEsimCreated: json["is_esim_created"]?.toString(),
        createdAt: json["created_at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "plan_id": planId,
        "price": price,
        "is_esim_created": isEsimCreated,
        "created_at": createdAt,
      };
}
