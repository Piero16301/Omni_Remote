import 'package:flutter/material.dart';

class ThemeHelper {
  static String getThemeName(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.light:
        return 'LIGHT';
      case ThemeMode.dark:
        return 'DARK';
      case ThemeMode.system:
        return 'SYSTEM';
    }
  }

  static ThemeMode getThemeByName(String themeName) {
    switch (themeName.toUpperCase()) {
      case 'LIGHT':
        return ThemeMode.light;
      case 'DARK':
        return ThemeMode.dark;
      case 'SYSTEM':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
}
