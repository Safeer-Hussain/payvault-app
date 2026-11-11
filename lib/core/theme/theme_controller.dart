import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class ThemeController extends GetxController {
  final SharedPreferences _prefs;

  ThemeController(this._prefs);

  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    final savedMode = _prefs.getString(AppConstants.keyThemeMode);
    if (savedMode == 'light') {
      themeMode.value = ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.dark;
    }
  }

  Future<void> toggleTheme() async {
    if (themeMode.value == ThemeMode.dark) {
      themeMode.value = ThemeMode.light;
      await _prefs.setString(AppConstants.keyThemeMode, 'light');
    } else {
      themeMode.value = ThemeMode.dark;
      await _prefs.setString(AppConstants.keyThemeMode, 'dark');
    }
    Get.changeThemeMode(themeMode.value);
    update();
  }

  Future<void> setTheme(ThemeMode mode) async {
    themeMode.value = mode;
    await _prefs.setString(
      AppConstants.keyThemeMode,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
    Get.changeThemeMode(mode);
    update();
  }
}
