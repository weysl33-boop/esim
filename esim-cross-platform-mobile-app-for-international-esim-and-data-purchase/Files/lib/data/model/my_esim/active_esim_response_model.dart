// To parse this JSON data, do
//
//     final activeEsimResponseModel = activeEsimResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:esim/data/model/auth/login/login_response_model.dart';

ActiveEsimResponseModel activeEsimResponseModelFromJson(String str) => ActiveEsimResponseModel.fromJson(json.decode(str));

String activeEsimResponseModelToJson(ActiveEsimResponseModel data) => json.encode(data.toJson());

class ActiveEsimResponseModel {
  final String? remark;
  final String? status;
  final Message? message;
  final Data? data;

  ActiveEsimResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory ActiveEsimResponseModel.fromJson(Map<String, dynamic> json) => ActiveEsimResponseModel(
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
  final Esims? esims;

  Data({
    this.esims,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        esims: json["esims"] == null ? null : Esims.fromJson(json["esims"]),
      );

  Map<String, dynamic> toJson() => {
        "esims": esims?.toJson(),
      };
}

class Esims {
  final String? currentPage;
  final List<ActiveESIMPlanData>? data;
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

  Esims({
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

  factory Esims.fromJson(Map<String, dynamic> json) => Esims(
        currentPage: json["current_page"]?.toString(),
        data: json["data"] == null ? [] : List<ActiveESIMPlanData>.from(json["data"]!.map((x) => ActiveESIMPlanData.fromJson(x))),
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

class ActiveESIMPlanData {
  final String? id;
  final String? orderItemId;
  final String? serialNumber;
  final String? iccid;
  final String? phoneNumber;
  final String? qrCode;
  final String? qrCodeImage;
  final String? expiryDate;
  final String? createdAt;
  final String? price;
  final String? readableDataVolume;
  final String? readableVoiceQuantity;
  final String? readableSmsQuantity;
  final String? formattedExpiryDate;
  final String? image;
  final OrderItem? orderItem;

  ActiveESIMPlanData({
    this.id,
    this.orderItemId,
    this.serialNumber,
    this.iccid,
    this.phoneNumber,
    this.qrCode,
    this.qrCodeImage,
    this.expiryDate,
    this.createdAt,
    this.price,
    this.readableDataVolume,
    this.readableVoiceQuantity,
    this.readableSmsQuantity,
    this.formattedExpiryDate,
    this.image,
    this.orderItem,
  });

  factory ActiveESIMPlanData.fromJson(Map<String, dynamic> json) => ActiveESIMPlanData(
        id: json["id"]?.toString(),
        orderItemId: json["order_item_id"]?.toString(),
        serialNumber: json["serial_number"]?.toString(),
        iccid: json["iccid"]?.toString(),
        phoneNumber: json["phone_number"]?.toString(),
        qrCode: json["qr_code"]?.toString(),
        qrCodeImage: json["qr_code_image"]?.toString(),
        expiryDate: json["expiry_date"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        price: json["price"]?.toString(),
        readableDataVolume: json["readable_data_volume"]?.toString(),
        readableVoiceQuantity: json["readable_voice_quantity"]?.toString(),
        readableSmsQuantity: json["readable_sms_quantity"]?.toString(),
        formattedExpiryDate: json["formatted_expiry_date"]?.toString(),
        image: json["image"]?.toString(),
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
        "price": price,
        "readable_data_volume": readableDataVolume,
        "readable_voice_quantity": readableVoiceQuantity,
        "readable_sms_quantity": readableSmsQuantity,
        "formatted_expiry_date": formattedExpiryDate,
        "image": image,
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
  final String? areaCoverage;
  final String? regionId;
  final Region? region;
  final List<Country>? countries;

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
    this.areaCoverage,
    this.regionId,
    this.region,
    this.countries,
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
        areaCoverage: json["area_coverage"]?.toString(),
        regionId: json["region_id"]?.toString(),
        region: json["region"] == null ? null : Region.fromJson(json["region"]),
        countries: json["countries"] == null ? [] : List<Country>.from(json["countries"]!.map((x) => Country.fromJson(x))),
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
        "area_coverage": areaCoverage,
        "region_id": regionId,
        "region": region?.toJson(),
        "countries": countries == null ? [] : List<dynamic>.from(countries!.map((x) => x.toJson())),
      };
}

class Country {
  final String? id;
  final String? name;
  final String? image;
  final Pivot? pivot;

  Country({
    this.id,
    this.name,
    this.image,
    this.pivot,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json["id"]?.toString(),
        name: json["name"]?.toString(),
        image: json["image"]?.toString(),
        pivot: json["pivot"] == null ? null : Pivot.fromJson(json["pivot"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "pivot": pivot?.toJson(),
      };
}

class Pivot {
  final String? planId;
  final String? countryId;

  Pivot({
    this.planId,
    this.countryId,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) => Pivot(
        planId: json["plan_id"]?.toString(),
        countryId: json["country_id"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "plan_id": planId,
        "country_id": countryId,
      };
}

class Region {
  final String? id;
  final String? name;
  final String? regionImage;

  Region({
    this.id,
    this.name,
    this.regionImage,
  });

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        id: json["id"]?.toString(),
        name: json["name"]?.toString(),
        regionImage: json["region_image"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "region_image": regionImage,
      };
}
