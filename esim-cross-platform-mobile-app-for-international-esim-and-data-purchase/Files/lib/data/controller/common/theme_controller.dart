import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/theme/theme.dart';

class ThemeController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  ThemeController({required this.sharedPreferences}) {
    _loadCurrentTheme();
  }

  void _loadCurrentTheme() {
    _darkTheme = sharedPreferences.getBool(SharedPreferenceHelper.theme) ?? false;

    update();
  }

  void toggleTheme() {
    _darkTheme = !_darkTheme;
    sharedPreferences.setBool(SharedPreferenceHelper.theme, _darkTheme);
    if (_darkTheme) {
      Get.changeThemeMode(ThemeMode.dark);
      Get.changeTheme(AppTheme.darkThemeData);
    } else {
      Get.changeThemeMode(ThemeMode.light);
      Get.changeTheme(AppTheme.lightThemeData);
    }

    _loadCurrentTheme();
    // MyUtils.allScreen();
    update();
  }
}
