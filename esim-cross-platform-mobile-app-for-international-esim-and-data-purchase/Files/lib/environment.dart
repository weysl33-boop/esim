// ignore_for_file: constant_identifier_names

import 'package:esim/core/utils/url_container.dart';

class Environment {
/* ATTENTION Please update your desired data. */

  static const String appName = 'eSim';
  static const String appSubTitle = 'Cross Platform Mobile App for International eSim and Data Purchase';
  static const String appWebUrl = UrlContainer.domainUrl;
  static const String version = '1.0.0';

  static const bool DEV_MODE = false;

  static const APP_VIBRATION = true;

  //Guest MODE
  static const bool isGuestModeEnable = true;

  //App GS Settings Auth Key
  static const String appAuthKey = "esim*123"; //Don't touch here

  // LOGIN AND REG PART
  static String defaultPhoneCode = "1"; //don't put + here
  static String defaultCountryCode = "US";
}
