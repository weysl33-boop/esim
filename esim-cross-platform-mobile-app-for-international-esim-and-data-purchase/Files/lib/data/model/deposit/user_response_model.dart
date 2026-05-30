import 'dart:convert';
import 'package:esim/data/model/auth/login/login_response_model.dart';
import 'package:esim/data/model/user/user_model.dart';

UserResponseModel userResponseModelFromJson(String str) => UserResponseModel.fromJson(json.decode(str));

String userResponseModelToJson(UserResponseModel data) => json.encode(data.toJson());

class UserResponseModel {
  final String? remark;
  final String? status;
  final Message? message;
  final Data? data;

  UserResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) => UserResponseModel(
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
  final User? user;

  Data({
    this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
      };
}
