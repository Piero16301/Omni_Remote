import 'package:flutter/material.dart';

class ThemeHelper {
  static const Map<String, ThemeMode> themeMap = <String, ThemeMode>{
    'LIGHT': ThemeMode.light,
    'DARK': ThemeMode.dark,
  };

  static ThemeMode getThemeByName(String themeName) {
    return themeMap[themeName.toUpperCase()] ?? ThemeMode.light;
  }
}
