import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:esim/core/utils/app_status.dart';
import 'package:esim/core/utils/my_color.dart';
import '../../environment.dart';
import '../helper/string_format_helper.dart';
import 'my_strings.dart';

class MyUtils {
  static void splashScreen() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: MyColor.getSystemStatusBarColor(), statusBarIconBrightness: MyColor.getSystemStatusBarBrightness(), systemNavigationBarColor: MyColor.getSystemStatusBarColor(), systemNavigationBarIconBrightness: MyColor.getSystemNavigationBarBrightness()));
  }

  static void allScreen() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: MyColor.getSystemStatusBarColor(), statusBarIconBrightness: MyColor.getSystemStatusBarBrightness(), systemNavigationBarColor: MyColor.getSystemNavigationBarColor(), systemNavigationBarIconBrightness: MyColor.getSystemNavigationBarBrightness()));
  }

  static dynamic getShadow() {
    return [
      BoxShadow(blurRadius: 15.0, offset: const Offset(0, 25), color: Colors.grey.shade500.withValues(alpha: 0.6), spreadRadius: -35.0),
    ];
  }

  static Color hexToColor(String hexCode) {
    try {
      return Color(int.parse(hexCode, radix: 16) + 0xFF000000);
    } catch (e) {
      return MyColor.getPrimaryColor();
    }
  }

  static String timeAgo(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      DateTime now = DateTime.now();
      Duration difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return '${difference.inSeconds} seconds ago';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        int weeks = (difference.inDays / 7).floor();
        return '$weeks week${weeks > 1 ? 's' : ''} ago';
      } else if (difference.inDays < 365) {
        int months = (difference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      } else {
        int years = (difference.inDays / 365).floor();
        return '$years year${years > 1 ? 's' : ''} ago';
      }
    } catch (e) {
      return 'Invalid timestamp';
    }
  }

  static dynamic getBottomNavShadow() {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 0),
      ),
    ];
  }

  static dynamic getBottomSheetShadow() {
    return [
      BoxShadow(
        color: Colors.grey.shade400.withValues(alpha: 0.08),
        spreadRadius: 3,
        blurRadius: 4,
        offset: const Offset(0, 3),
      ),
    ];
  }

  static dynamic getCardShadow() {
    return [
      BoxShadow(
        color: Colors.grey.shade400.withValues(alpha: 0.05),
        spreadRadius: 2,
        blurRadius: 2,
        offset: const Offset(0, 3),
      ),
    ];
  }

  static Future<void> vibrationOn() async {
    try {
      if (Environment.APP_VIBRATION) {
        HapticFeedback.vibrate();
      }
    } catch (e) {
      printX(e.toString());
    }
  }

  static String getOperationTitle(String value) {
    String number = value;
    RegExp regExp = RegExp(r'^(\d+)(\w+)$');
    Match? match = regExp.firstMatch(number);
    if (match != null) {
      String? num = match.group(1) ?? '';
      String? unit = match.group(2) ?? '';
      String title = '${MyStrings.last.tr} $num ${unit.capitalizeFirst}';
      return title.tr;
    } else {
      return value.tr;
    }
  }

  static String formatNumberAbbreviated(String numberValue) {
    try {
      double number = double.parse(numberValue.toString());
      if (number >= 1e9) {
        return '${(number / 1e9).toStringAsFixed(2)}B';
      } else if (number >= 1e6) {
        return '${(number / 1e6).toStringAsFixed(2)}M';
      } else if (number >= 1e3) {
        return '${(number / 1e3).toStringAsFixed(2)}K';
      } else {
        return number.toStringAsFixed(2);
      }
    } catch (e) {
      printX(e.toString());
      return "0.0";
    }
  }

  static bool isFileTypeImage(String img) {
    try {
      String type = img.split('.').last.toLowerCase();
      if (type == "png") {
        return true;
      } else if (type == "jpg") {
        return true;
      } else if (type == "jpeg") {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static TextInputType getInputTextFieldType(String type) {
    if (type == "email") {
      return TextInputType.emailAddress;
    } else if (type == "number") {
      return TextInputType.number;
    } else if (type == "url") {
      return TextInputType.url;
    }
    return TextInputType.text;
  }

  static bool getInputType(String type) {
    if (type == "text") {
      return true;
    } else if (type == "email") {
      return true;
    } else if (type == "number") {
      return true;
    } else if (type == "url") {
      return true;
    }
    return false;
  }

  static Color getAdsStatusColor(String type) {
    if (type == AppStatus.ENABLE) {
      return MyColor.greenSuccessColor;
    } else {
      return MyColor.pendingColor;
    }
  }

  static String getAdsStatus(String type) {
    if (type == AppStatus.ENABLE) {
      return "Enabled";
    } else {
      return "Disabled";
    }
  }

  static Color getAdsTypeColor(String type) {
    if (type == AppStatus.P2P_AD_TYPE_BUY) {
      return MyColor.greenSuccessColor;
    } else {
      return MyColor.redCancelTextColor;
    }
  }

  static String getAdsType(String type) {
    if (type == AppStatus.P2P_AD_TYPE_BUY) {
      return MyStrings.buy;
    } else {
      return MyStrings.sell;
    }
  }

  static String getTradeStatus(String type) {
    if (type == AppStatus.P2P_TRADE_PENDING) {
      return "Pending";
    } else if (type == AppStatus.P2P_TRADE_COMPLETED) {
      return "Completed";
    } else if (type == AppStatus.P2P_TRADE_PAID) {
      return "Paid";
    } else if (type == AppStatus.P2P_TRADE_REPORTED) {
      return "Reported";
    } else {
      return "Canceled";
    }
  }

  static Color getTradeStatusColor(String type) {
    if (type == AppStatus.P2P_TRADE_PENDING) {
      return MyColor.pendingColor;
    } else if (type == AppStatus.P2P_TRADE_COMPLETED) {
      return MyColor.greenSuccessColor;
    } else if (type == AppStatus.P2P_TRADE_PAID) {
      return MyColor.primaryColor;
    } else if (type == AppStatus.P2P_TRADE_REPORTED) {
      return MyColor.colorYellow;
    } else {
      return MyColor.redCancelTextColor;
    }
  }
  //binary

  static String getBinaryTradeStatus(String type) {
    if (type == AppStatus.BINARY_TRADE_WIN) {
      return "Win";
    } else if (type == AppStatus.BINARY_TRADE_LOSE) {
      return "Lose";
    } else if (type == AppStatus.BINARY_TRADE_PENDING) {
      return "Pending";
    } else {
      return "Refund";
    }
  }

  static Color getBinaryTradeStatusColor(String type) {
    if (type == AppStatus.BINARY_TRADE_WIN) {
      return MyColor.greenSuccessColor;
    } else if (type == AppStatus.BINARY_TRADE_LOSE) {
      return MyColor.redCancelTextColor;
    } else if (type == AppStatus.BINARY_TRADE_PENDING) {
      return MyColor.pendingColor;
    } else {
      return MyColor.primaryColor;
    }
  }

  static int calculateDurationFromCreated(String createdAt, String durations, {int forceAddSeconds = 0}) {
    try {
      var duration = int.tryParse(durations) ?? 0;
      final createdTime = DateTime.parse(createdAt); // Parse the created_at date
      final currentTime = DateTime.now(); // Current time
      final tradeEndTime = createdTime.add(Duration(seconds: duration)); // Calculate end time

      // Calculate remaining duration
      final remainingDuration = tradeEndTime.difference(currentTime).inSeconds + forceAddSeconds;

      // Ensure duration is non-negative
      return remainingDuration > 0 ? remainingDuration : 0;
    } catch (e) {
      // Handle parsing errors
      printX("Error parsing createdAt or duration: $e");
      return 0;
    }
  }

  static int calculateDurationFromMin(String min) {
    try {
      double duration = double.tryParse(min) ?? 0.0;
      int remainSec = (duration * 60).round();
      return max(0, remainSec);
    } catch (e) {
      // Handle parsing errors
      printX("Error parsing createdAt or duration: $e");
      return 0;
    }
  }

  static Icon getFileIcon(String path, {double size = 24.0, Color? color}) {
    // Map file types to specific icons and default colors
    if (path.endsWith('.pdf')) {
      return Icon(Icons.picture_as_pdf, color: color ?? Colors.red, size: size);
    } else if (path.endsWith('.doc') || path.endsWith('.docx')) {
      return Icon(Icons.description, color: color ?? Colors.blue, size: size);
    } else if (path.endsWith('.xls') || path.endsWith('.xlsx')) {
      return Icon(Icons.table_chart, color: color ?? Colors.green, size: size);
    } else if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png')) {
      return Icon(Icons.image, color: color ?? Colors.orange, size: size);
    } else if (path.endsWith('.mp4') || path.endsWith('.mov')) {
      return Icon(Icons.videocam, color: color ?? Colors.purple, size: size);
    } else if (path.endsWith('.mp3') || path.endsWith('.wav')) {
      return Icon(Icons.audiotrack, color: color ?? Colors.teal, size: size);
    } else {
      // Default icon for other file types
      return Icon(Icons.insert_drive_file, color: color ?? Colors.grey, size: size);
    }
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return MyStrings.goodMorning.tr;
    if (hour >= 12 && hour < 17) return MyStrings.goodAfternoon.tr;
    if (hour >= 17 && hour < 21) return MyStrings.goodEvening.tr;
    return MyStrings.goodNight.tr;
  }

  static String getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return '☀️';
    if (hour >= 12 && hour < 17) return '🌤️';
    if (hour >= 17 && hour < 21) return '🌆';
    return '🌙';
  }
}
