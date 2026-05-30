import 'dart:convert';
import 'package:esim/data/model/auth/login/login_response_model.dart';

MyActiveEsimDetailsResponseModel myActiveEsimDetailsResponseModelFromJson(String str) => MyActiveEsimDetailsResponseModel.fromJson(json.decode(str));

String myActiveEsimDetailsResponseModelToJson(MyActiveEsimDetailsResponseModel data) => json.encode(data.toJson());

class MyActiveEsimDetailsResponseModel {
  final String? remark;
  final String? status;
  final Message? message;
  final Data? data;

  MyActiveEsimDetailsResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory MyActiveEsimDetailsResponseModel.fromJson(Map<String, dynamic> json) => MyActiveEsimDetailsResponseModel(
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
  final Esim? esim;

  Data({
    this.esim,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        esim: json["esim"] == null ? null : Esim.fromJson(json["esim"]),
      );

  Map<String, dynamic> toJson() => {
        "esim": esim?.toJson(),
      };
}

class Esim {
  final String? id;
  final String? orderItemId;
  final String? serialNumber;
  final String? iccid;
  final String? phoneNumber;
  final String? qrCode;
  final String? qrCodeImage;
  final String? expiryDate;
  final String? createdAt;
  final bool? isReloadable;
  final bool? isRefundable;
  final String? price;
  final String? readableDataVolume;
  final String? readableVoiceQuantity;
  final String? readableSmsQuantity;
  final String? formattedExpiryDate;
  final Remaining? remaining;
  final OrderItem? orderItem;

  Esim({
    this.id,
    this.orderItemId,
    this.serialNumber,
    this.iccid,
    this.phoneNumber,
    this.qrCode,
    this.qrCodeImage,
    this.expiryDate,
    this.createdAt,
    this.isReloadable,
    this.isRefundable,
    this.price,
    this.readableDataVolume,
    this.readableVoiceQuantity,
    this.readableSmsQuantity,
    this.formattedExpiryDate,
    this.remaining,
    this.orderItem,
  });

  factory Esim.fromJson(Map<String, dynamic> json) => Esim(
        id: json["id"]?.toString(),
        orderItemId: json["order_item_id"]?.toString(),
        serialNumber: json["serial_number"]?.toString(),
        iccid: json["iccid"]?.toString(),
        phoneNumber: json["phone_number"]?.toString(),
        qrCode: json["qr_code"]?.toString(),
        qrCodeImage: json["qr_code_image"]?.toString(),
        expiryDate: json["expiry_date"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        isReloadable: json["is_reloadable"],
        isRefundable: json["is_refundable"],
        price: json["price"]?.toString(),
        readableDataVolume: json["readable_data_volume"]?.toString(),
        readableVoiceQuantity: json["readable_voice_quantity"]?.toString(),
        readableSmsQuantity: json["readable_sms_quantity"]?.toString(),
        formattedExpiryDate: json["formatted_expiry_date"]?.toString(),
        remaining: json["remaining"] == null ? null : Remaining.fromJson(json["remaining"]),
        orderItem: json["order_item"] == null ? null : OrderItem.fromJson(json["order_item"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_item_id": orderItemId,
        "serial_number": serialNumber,
        "iccid": iccid,
        "phone_number": phoneNumber,
        "qr_code": qrCode,
        "qr_code_image": qrCodeImage,
        "expiry_date": expiryDate,
        "created_at": createdAt,
        "is_reloadable": isReloadable,
        "is_refundable": isRefundable,
        "price": price,
        "readable_data_volume": readableDataVolume,
        "readable_voice_quantity": readableVoiceQuantity,
        "readable_sms_quantity": readableSmsQuantity,
        "formatted_expiry_date": formattedExpiryDate,
        "remaining": remaining?.toJson(),
        "order_item": orderItem?.toJson(),
      };
}

class OrderItem {
  final String? id;
  final String? orderId;
  final String? planId;
  final Plan? plan;

  OrderItem({
    this.id,
    this.orderId,
    this.planId,
    this.plan,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json["id"]?.toString(),
        orderId: json["order_id"]?.toString(),
        planId: json["plan_id"]?.toString(),
        plan: json["plan"] == null ? null : Plan.fromJson(json["plan"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "plan_id": planId,
        "plan": plan?.toJson(),
      };
}

class Plan {
  final String? id;
  final String? name;
  final String? packageType;
  final String? dataVolume;
  final String? voiceQuantity;
  final String? smsQuantity;
  final String? retailPrice;
  final String? reloadable;
  final String? refundable;
  final String? esimProviderId;
  final EsimProvider? esimProvider;

  Plan({
    this.id,
    this.name,
    this.packageType,
    this.dataVolume,
    this.voiceQuantity,
    this.smsQuantity,
    this.retailPrice,
    this.reloadable,
    this.refundable,
    this.esimProviderId,
    this.esimProvider,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json["id"]?.toString(),
        name: json["name"]?.toString(),
        packageType: json["package_type"]?.toString(),
        dataVolume: json["data_volume"]?.toString(),
        voiceQuantity: json["voice_quantity"]?.toString(),
        smsQuantity: json["sms_quantity"]?.toString(),
        retailPrice: json["retail_price"]?.toString(),
        reloadable: json["reloadable"]?.toString(),
        refundable: json["refundable"]?.toString(),
        esimProviderId: json["esim_provider_id"]?.toString(),
        esimProvider: json["esim_provider"] == null ? null : EsimProvider.fromJson(json["esim_provider"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "package_type": packageType,
        "data_volume": dataVolume,
        "voice_quantity": voiceQuantity,
        "sms_quantity": smsQuantity,
        "retail_price": retailPrice,
        "reloadable": reloadable,
        "refundable": refundable,
        "esim_provider_id": esimProviderId,
        "esim_provider": esimProvider?.toJson(),
      };
}

class EsimProvider {
  final String? id;
  final String? provider;
  final String? slug;
  final String? link;
  final String? currency;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  EsimProvider({
    this.id,
    this.provider,
    this.slug,
    this.link,
    this.currency,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory EsimProvider.fromJson(Map<String, dynamic> json) => EsimProvider(
        id: json["id"]?.toString(),
        provider: json["provider"]?.toString(),
        slug: json["slug"]?.toString(),
        link: json["link"]?.toString(),
        currency: json["currency"]?.toString(),
        status: json["status"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "provider": provider,
        "slug": slug,
        "link": link,
        "currency": currency,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

class Remaining {
  final String? remainingCapacity;
  final String? remainingVoice;
  final String? remainingSms;
  final String? planExpiry;
  final String? esimExpiry;

  Remaining({
    this.remainingCapacity,
    this.remainingVoice,
    this.remainingSms,
    this.planExpiry,
    this.esimExpiry,
  });

  factory Remaining.fromJson(Map<String, dynamic> json) => Remaining(
        remainingCapacity: json["remaining_capacity"]?.toString(),
        remainingVoice: json["remaining_voice"]?.toString(),
        remainingSms: json["remaining_sms"]?.toString(),
        planExpiry: json["plan_expiry"]?.toString(),
        esimExpiry: json["esim_expiry"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "remaining_capacity": remainingCapacity,
        "remaining_voice": remainingVoice,
        "remaining_sms": remainingSms,
        "plan_expiry": planExpiry,
        "esim_expiry": esimExpiry,
      };
}
