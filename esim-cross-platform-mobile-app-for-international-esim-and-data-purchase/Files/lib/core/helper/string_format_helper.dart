import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../environment.dart';
import '../utils/my_strings.dart';

class StringConverter {
  /// =========================
  /// DAYS CONVERTER
  /// =========================

  /// =========================
  /// VOICE MINUTES CONVERTER
  /// =========================
  static double voiceInMinutes(double qty, {String unit = 'minutes'}) {
    switch (unit.toLowerCase()) {
      case 'minute':
      case 'minutes':
        return qty;
      case 'hour':
      case 'hours':
        return qty * 60;
      case 'day':
      case 'days':
        return qty * 1440; // 24 * 60
      case 'second':
      case 'seconds':
        return qty / 60;
      default:
        throw ArgumentError('Unsupported unit: $unit');
    }
  }

  /// =========================
  /// DATA VOLUME CONVERTER
  /// =========================
  static dynamic dataVolume(
    String bytes, {
    int precision = 2,
    bool isString = false,
  }) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];

    double dataBytes = double.tryParse(bytes) ?? 0;

    dataBytes = max(dataBytes, 0);
    int power = dataBytes > 0 ? (log(dataBytes) / log(1024)).floor() : 0;
    power = min(power, units.length - 1);

    double value = dataBytes / pow(1024, power);

    if (isString) {
      return '${value.toStringAsFixed(precision)} ${units[power]}';
    }

    return {
      'capacity': double.parse(value.toStringAsFixed(precision)),
      'unit': units[power],
    };
  }

  static String formatNumber(String value, {int precision = 2}) {
    try {
      double number = double.parse(value.toString() == "null" ? '0.0' : value);
      String b = number.toStringAsFixed(precision);
      return b;
    } catch (e) {
      return "0";
    }
  }

  static int formatInt(String value) {
    try {
      return int.parse(value.toString() == "null" ? '0' : value);
    } catch (e) {
      return 0;
    }
  }

  static double formatDouble(String value, {int precision = 2}) {
    return (double.tryParse(value) ?? 0.0).toPrecision(precision);
  }

  static String hideBalanceText({bool isShow = false, required String balance}) {
    try {
      return isShow ? balance : '**********';
    } catch (e) {
      return "0";
    }
  }

  // static String formatNumberPrecision(String value, {int precision = 5}) {
  //   try {
  //     double number = double.parse(value.toString() == "null" ? '0.0' : value);
  //     String formattedNumber = number.toStringAsFixed(precision);

  //     List<String> parts = formattedNumber.split('.');
  //     if (parts.length == 2 && parts[0].length > precision) {
  //       // If part before the decimal point has more than 5 digits, limit to 2 digits after the decimal point
  //       formattedNumber = "${parts[0].substring(0, precision)}.${parts[1].substring(0, 2)}";
  //     }

  //     return formattedNumber;
  //   } catch (e) {
  //     return "0";
  //   }
  // }
  static String formatNumberPrecision(String value, {int defaultPrecision = 2, int precision = 8}) {
    try {
      double number = double.parse(value.toString() == "null" ? '0.0' : value);

      // Split the number into integer and fractional parts
      List<String> parts = number.toString().split('.');

      if (parts.length == 2) {
        String fractionalPart = parts[1];

        // Check if the fractional part contains any non-zero digits
        if (fractionalPart.replaceAll('0', '').isEmpty) {
          // Fractional part is only zeros, show with default precision
          return number.toStringAsFixed(defaultPrecision);
        } else {
          // Fractional part has significant digits, show with extended precision
          return number.toStringAsFixed(precision);
        }
      }

      return number.toStringAsFixed(defaultPrecision);
    } catch (e) {
      return "0";
    }
  }

  static String removeQuotationAndSpecialCharacterFromString(String value) {
    try {
      String formatedString = value.replaceAll('"', '').replaceAll('[', '').replaceAll(']', '');
      return formatedString;
    } catch (e) {
      return value;
    }
  }

  static String replaceUnderscoreWithSpace(String value) {
    try {
      String formatedString = value.replaceAll('_', ' ');
      String v = formatedString.split(" ").map((str) => str.capitalize).join(" ");
      return v;
    } catch (e) {
      return value;
    }
  }

  static String getFormatedDateWithStatus(String inputValue) {
    String value = inputValue;
    try {
      var list = inputValue.split(' ');
      var dateSection = list[0].split('-');
      var timeSection = list[1].split(':');
      int year = int.parse(dateSection[0]);
      int month = int.parse(dateSection[1]);
      int day = int.parse(dateSection[2]);
      int hour = int.parse(timeSection[0]);
      int minute = int.parse(timeSection[1]);
      int second = int.parse(timeSection[2]);
      final startTime = DateTime(year, month, day, hour, minute, second);
      final currentTime = DateTime.now();

      int dayDef = currentTime.difference(startTime).inDays;
      int hourDef = currentTime.difference(startTime).inHours;
      final minDef = currentTime.difference(startTime).inMinutes;
      final secondDef = currentTime.difference(startTime).inSeconds;

      if (dayDef == 0) {
        if (hourDef <= 0) {
          if (minDef <= 0) {
            value = '$secondDef ${MyStrings.secondAgo}'.tr;
          } else {
            value = '$hourDef ${MyStrings.minutesAgo}'.tr;
          }
        } else {
          value = '$hourDef ${MyStrings.hourAgo}'.tr;
        }
      } else {
        value = '$dayDef ${MyStrings.daysAgo}'.tr;
      }
    } catch (e) {
      value = inputValue;
    }

    return value;
  }

  static String getTrailingExtension(int number) {
    List<String> list = ['th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th'];
    if (((number % 100) >= 11) && ((number % 100) <= 13)) {
      return '${number}th';
    } else {
      int value = (number % 10).toInt();
      return '$number${list[value]}';
    }
  }

  static String addLeadingZero(String value) {
    return value.padLeft(2, '0');
  }

  static String sum(String first, String last, {int precision = 2}) {
    double firstNum = double.tryParse(first) ?? 0;
    double secondNum = double.tryParse(last) ?? 0;
    double result = firstNum + secondNum;
    String formatedResult = formatNumber(result.toString(), precision: precision);
    return formatedResult;
  }

  static String showPercent(String curSymbol, String s) {
    double value = 0;
    value = double.tryParse(s) ?? 0;
    if (value > 0) {
      return ' + $curSymbol$value';
    } else {
      return '';
    }
  }

  static String mul(String first, String second) {
    double result = (double.tryParse(first) ?? 0) * (double.tryParse(second) ?? 0);
    return StringConverter.formatNumber(result.toString());
  }

  static String calculateRate(String amount, String rate, {int precision = 2}) {
    double result = (double.tryParse(amount) ?? 0) / (double.tryParse(rate) ?? 0);
    return StringConverter.formatNumber(result.toString(), precision: precision);
  }

  static String convertSecondToMinute(String second) {
    double value = double.tryParse(second) ?? 0;
    int minute = (value / 60).floor();
    double secondInMinute = value % 60;
    return minute > 1 ? '$minute:${secondInMinute.toInt()}' : '0:${secondInMinute.toInt()}';
  }
}

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}

//Custom
extension StringExtension on String {
  //  rKV => Replace key Values
  String rKv(Map<String, String> replacements) {
    String result = this;
    replacements.forEach((key, value) {
      result = result.replaceAll("{$key}", value);
    });
    return result;
  }
}

void printX(Object? object) {
  if (Environment.DEV_MODE) {
    if (kDebugMode) {
      print(object);
    }
  }
}
