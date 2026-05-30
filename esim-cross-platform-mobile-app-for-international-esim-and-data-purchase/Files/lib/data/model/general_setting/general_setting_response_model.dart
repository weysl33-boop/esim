// To parse this JSON data, do
//
//     final generalSettingResponseModel = generalSettingResponseModelFromJson(jsonString);

import 'dart:convert';

import '../auth/login/login_response_model.dart';

GeneralSettingResponseModel generalSettingResponseModelFromJson(String str) => GeneralSettingResponseModel.fromJson(json.decode(str));

String generalSettingResponseModelToJson(GeneralSettingResponseModel data) => json.encode(data.toJson());

class GeneralSettingResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  GeneralSettingResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory GeneralSettingResponseModel.fromJson(Map<String, dynamic> json) => GeneralSettingResponseModel(
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
  GeneralSetting? generalSetting;
  String? socialLoginRedirect;
  Data({
    this.generalSetting,
    this.socialLoginRedirect,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        generalSetting: json["general_setting"] == null ? null : GeneralSetting.fromJson(json["general_setting"]),
        socialLoginRedirect: json["social_login_redirect"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "general_setting": generalSetting?.toJson(),
        "social_login_redirect": socialLoginRedirect,
      };
}

class GeneralSetting {
  int? id;
  String? siteName;
  String? curText;
  String? curSym;
  String? smsFrom;
  PusherConfig? pusherConfig;
  String? baseColor;
  String? kv;
  String? ev;
  String? en;
  String? sv;
  String? sn;
  String? forceSsl;
  String? maintenanceMode;
  String? securePassword;
  String? agree;
  String? multiLanguage;
  String? registration;
  String? activeTemplate;
  String? defaultTheme;
  String? systemCustomized;
  String? depositCommission;
  String? tradeCommission;
  String? binaryDemoTrade;
  String? lastCron;
  String? allowDecimalAfterNumber;
  String? p2PTradeCharge;
  String? otherUserTransferCharge;
  WalletTypes? walletTypes;
  String? createdAt;
  String? updatedAt;
  String? googleLogin;
  String? facebookLogin;
  String? linkedinLogin;
  SocialiteCredentials? socialiteCredentials;
  GeneralSetting({
    this.id,
    this.siteName,
    this.curText,
    this.curSym,
    this.smsFrom,
    this.pusherConfig,
    this.baseColor,
    this.binaryDemoTrade,
    this.kv,
    this.ev,
    this.en,
    this.sv,
    this.sn,
    this.forceSsl,
    this.maintenanceMode,
    this.securePassword,
    this.agree,
    this.multiLanguage,
    this.registration,
    this.activeTemplate,
    this.defaultTheme,
    this.systemCustomized,
    this.depositCommission,
    this.tradeCommission,
    this.lastCron,
    this.allowDecimalAfterNumber,
    this.p2PTradeCharge,
    this.otherUserTransferCharge,
    this.walletTypes,
    this.createdAt,
    this.updatedAt,
    this.googleLogin,
    this.facebookLogin,
    this.linkedinLogin,
    this.socialiteCredentials,
  });

  factory GeneralSetting.fromJson(Map<String, dynamic> json) => GeneralSetting(
        id: json["id"],
        siteName: json["site_name"].toString(),
        curText: json["cur_text"].toString(),
        curSym: json["cur_sym"].toString(),
        smsFrom: json["sms_from"].toString(),
        pusherConfig: json["pusher_config"] == null ? null : PusherConfig.fromJson(json["pusher_config"]),
        baseColor: json["base_color"].toString(),
        binaryDemoTrade: json["binary_demo_trade"]?.toString(),
        kv: json["kv"].toString(),
        ev: json["ev"].toString(),
        en: json["en"].toString(),
        sv: json["sv"].toString(),
        sn: json["sn"].toString(),
        forceSsl: json["force_ssl"].toString(),
        maintenanceMode: json["maintenance_mode"].toString(),
        securePassword: json["secure_password"].toString(),
        agree: json["agree"].toString(),
        multiLanguage: json["multi_language"].toString(),
        registration: json["registration"].toString(),
        activeTemplate: json["active_template"].toString(),
        defaultTheme: json["default_theme"].toString(),
        systemCustomized: json["system_customized"].toString(),
        depositCommission: json["deposit_commission"].toString(),
        tradeCommission: json["trade_commission"].toString(),
        lastCron: json["last_cron"].toString(),
        allowDecimalAfterNumber: json["allow_decimal_after_number"].toString(),
        p2PTradeCharge: json["p2p_trade_charge"].toString(),
        otherUserTransferCharge: json["other_user_transfer_charge"].toString(),
        walletTypes: json["wallet_types"] == null ? null : WalletTypes.fromJson(json["wallet_types"]),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
        googleLogin: json["google_login"]?.toString(),
        facebookLogin: json["facebook_login"]?.toString(),
        linkedinLogin: json["linkedin_login"]?.toString(),
        socialiteCredentials: json["socialite_credentials"] == null ? null : SocialiteCredentials.fromJson(json["socialite_credentials"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "site_name": siteName,
        "cur_text": curText,
        "cur_sym": curSym,
        "sms_from": smsFrom,
        "pusher_config": pusherConfig?.toJson(),
        "base_color": baseColor,
        "binary_demo_trade": binaryDemoTrade,
        "kv": kv,
        "ev": ev,
        "en": en,
        "sv": sv,
        "sn": sn,
        "force_ssl": forceSsl,
        "maintenance_mode": maintenanceMode,
        "secure_password": securePassword,
        "agree": agree,
        "multi_language": multiLanguage,
        "registration": registration,
        "active_template": activeTemplate,
        "default_theme": defaultTheme,
        "system_customized": systemCustomized,
        "deposit_commission": depositCommission,
        "trade_commission": tradeCommission,
        "last_cron": lastCron,
        "allow_decimal_after_number": allowDecimalAfterNumber,
        "p2p_trade_charge": p2PTradeCharge,
        "other_user_transfer_charge": otherUserTransferCharge,
        "wallet_types": walletTypes?.toJson(),
        "created_at": createdAt,
        "updated_at": updatedAt,
        "google_login": googleLogin,
        "facebook_login": facebookLogin,
        "linkedin_login": linkedinLogin,
        "socialite_credentials": socialiteCredentials?.toJson(),
      };
}

class PusherConfig {
  String? pusherAppId;
  String? pusherAppKey;
  String? pusherAppSecret;
  String? pusherAppCluster;

  PusherConfig({
    this.pusherAppId,
    this.pusherAppKey,
    this.pusherAppSecret,
    this.pusherAppCluster,
  });

  factory PusherConfig.fromJson(Map<String, dynamic> json) => PusherConfig(
        pusherAppId: json["pusher_app_id"].toString(),
        pusherAppKey: json["pusher_app_key"].toString(),
        pusherAppSecret: json["pusher_app_secret"].toString(),
        pusherAppCluster: json["pusher_app_cluster"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "pusher_app_id": pusherAppId,
        "pusher_app_key": pusherAppKey,
        "pusher_app_secret": pusherAppSecret,
        "pusher_app_cluster": pusherAppCluster,
      };
}

class WalletTypes {
  WalletType? spot;
  WalletType? funding;

  WalletTypes({
    this.spot,
    this.funding,
  });

  factory WalletTypes.fromJson(Map<String, dynamic> json) => WalletTypes(
        spot: json["spot"] == null ? null : WalletType.fromJson(json["spot"]),
        funding: json["funding"] == null ? null : WalletType.fromJson(json["funding"]),
      );

  Map<String, dynamic> toJson() => {
        "spot": spot?.toJson(),
        "funding": funding?.toJson(),
      };
}

class WalletType {
  String? name;
  String? title;
  String? typeValue;
  String? description;
  Configuration? configuration;
  String? forFait;
  String? forCrypto;
  String? forFiat;

  WalletType({
    this.name,
    this.title,
    this.typeValue,
    this.description,
    this.configuration,
    this.forFait,
    this.forCrypto,
    this.forFiat,
  });

  factory WalletType.fromJson(Map<String, dynamic> json) => WalletType(
        name: json["name"].toString(),
        title: json["title"].toString(),
        typeValue: json["type_value"].toString(),
        description: json["description"].toString(),
        configuration: json["configuration"] == null ? null : Configuration.fromJson(json["configuration"]),
        forFait: json["for_fait"].toString(),
        forCrypto: json["for_crypto"].toString(),
        forFiat: json["for_fiat"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "title": title,
        "type_value": typeValue,
        "description": description,
        "configuration": configuration?.toJson(),
        "for_fait": forFait,
        "for_crypto": forCrypto,
        "for_fiat": forFiat,
      };
}

class Configuration {
  ConfigurationModel? deposit;
  ConfigurationModel? withdraw;
  ConfigurationModel? transferOtherUser;
  ConfigurationModel? transferOtherWallet;

  Configuration({
    this.deposit,
    this.withdraw,
    this.transferOtherUser,
    this.transferOtherWallet,
  });

  factory Configuration.fromJson(Map<String, dynamic> json) => Configuration(
        deposit: json["deposit"] == null ? null : ConfigurationModel.fromJson(json["deposit"]),
        withdraw: json["withdraw"] == null ? null : ConfigurationModel.fromJson(json["withdraw"]),
        transferOtherUser: json["transfer_other_user"] == null ? null : ConfigurationModel.fromJson(json["transfer_other_user"]),
        transferOtherWallet: json["transfer_other_wallet"] == null ? null : ConfigurationModel.fromJson(json["transfer_other_wallet"]),
      );

  Map<String, dynamic> toJson() => {
        "deposit": deposit?.toJson(),
        "withdraw": withdraw?.toJson(),
        "transfer_other_user": transferOtherUser?.toJson(),
        "transfer_other_wallet": transferOtherWallet?.toJson(),
      };
}

class ConfigurationModel {
  String? name;
  String? title;
  String? status;
  String? description;

  ConfigurationModel({
    this.name,
    this.title,
    this.status,
    this.description,
  });

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) => ConfigurationModel(
        name: json["name"].toString(),
        title: json["title"].toString(),
        status: json["status"].toString(),
        description: json["description"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "title": title,
        "status": status,
        "description": description,
      };
}

class SocialiteCredentials {
  SocialiteCredentialValue? google;
  SocialiteCredentialValue? facebook;
  SocialiteCredentialValue? linkedin;

  SocialiteCredentials({
    this.google,
    this.facebook,
    this.linkedin,
  });

  factory SocialiteCredentials.fromJson(Map<String, dynamic> json) => SocialiteCredentials(
        google: json["google"] == null ? null : SocialiteCredentialValue.fromJson(json["google"]),
        facebook: json["facebook"] == null ? null : SocialiteCredentialValue.fromJson(json["facebook"]),
        linkedin: json["linkedin"] == null ? null : SocialiteCredentialValue.fromJson(json["linkedin"]),
      );

  Map<String, dynamic> toJson() => {
        "google": google?.toJson(),
        "facebook": facebook?.toJson(),
        "linkedin": linkedin?.toJson(),
      };
}

class SocialiteCredentialValue {
  String? clientId;
  String? clientSecret;
  String? status;

  SocialiteCredentialValue({
    this.clientId,
    this.clientSecret,
    this.status,
  });

  factory SocialiteCredentialValue.fromJson(Map<String, dynamic> json) => SocialiteCredentialValue(
        clientId: json["client_id"].toString(),
        clientSecret: json["client_secret"].toString(),
        status: json["status"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "client_id": clientId,
        "client_secret": clientSecret,
        "status": status,
      };
}
