import 'package:intl/intl.dart';

class DateConverter {
  static String estimatedDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy - hh:mm:ss a').format(dateTime);
  }

  static String estimatedTime(DateTime dateTime) {
    return DateFormat('hh:mm:ss a').format(dateTime);
  }

  static String isoToLocalDateAndTime(String dateTime, {String errorResult = '--'}) {
    try {
      String date = '';
      if (dateTime.isEmpty || dateTime == 'null') {
        date = '';
      }
      try {
        date = DateFormat('dd MMM yyyy').format(isoStringToLocalDate(dateTime));
      } catch (v) {
        date = '';
      }
      String time = isoStringToLocalTimeOnly(dateTime);
      return '$date, $time';
    } catch (e) {
      return dateTime;
    }
  }

  static String estimatedDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  static String convertIsoToString(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) {
      return "";
    }

    try {
      DateTime time = DateTime.parse(dateTime).toLocal();
      return DateFormat('dd MMM yyyy hh:mm aa').format(time);
    } catch (e) {
      return "";
    }
  }

  static DateTime isoStringToLocalDate(String dateTime) {
    return DateTime.parse(dateTime).toLocal();
  }

  static String isoStringToLocalTimeOnly(String dateTime) {
    return DateFormat('hh:mm aa').format(isoStringToLocalDate(dateTime));
  }

  static String getFormatedSubtractTime(String time, {bool numericDates = false}) {
    final date1 = DateTime.now();
    final isoDate = isoStringToLocalDate(time);
    final difference = date1.difference(isoDate);

    if ((difference.inDays / 365).floor() >= 1) {
      int year = (difference.inDays / 365).floor();
      return '$year year ago';
    } else if ((difference.inDays / 30).floor() >= 1) {
      int month = (difference.inDays / 30).floor();
      return '$month month ago';
    } else if ((difference.inDays / 7).floor() >= 1) {
      int week = (difference.inDays / 7).floor();
      return '$week week ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }
}
