import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData lightTheme({
    required Color baseColor,
    required String fontFamily,
  }) {
    final colorScheme = ColorScheme.fromSeed(seedColor: baseColor);

    return ThemeData(
      textTheme: ThemeData.light().textTheme.apply(
            fontFamily: fontFamily,
          ),
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: baseColor,
      ),
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: colorScheme.onSurface,
        ),
        backgroundColor: colorScheme.surfaceContainer,
        closeIconColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  static ThemeData darkTheme({
    required Color baseColor,
    required String fontFamily,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: baseColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: fontFamily,
          ),
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: baseColor,
        brightness: Brightness.dark,
      ),
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: colorScheme.onSurface,
        ),
        backgroundColor: colorScheme.surfaceContainer,
        closeIconColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
