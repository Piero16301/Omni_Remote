import 'package:flutter/material.dart';
import 'package:omni_remote/app/app.dart';

class AppThemes {
  // static final TextStyle _textStyle = GoogleFonts.rubik();
  // static final TextStyle _textStyle = GoogleFonts.orbitron();

  static ThemeData lightTheme({
    required String baseColor,
    required String fontFamily,
  }) {
    final color = ColorHelper.getColorByName(baseColor);
    final colorScheme = ColorScheme.fromSeed(seedColor: color);
    final realFontFamily = AppVariables.getFontFamily(fontFamily);

    return ThemeData(
      textTheme: ThemeData.light().textTheme.apply(
            fontFamily: realFontFamily,
          ),
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
      ),
      cardTheme: CardThemeData(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
    );
  }

  static ThemeData darkTheme({
    required String baseColor,
    required String fontFamily,
  }) {
    final color = ColorHelper.getColorByName(baseColor);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Brightness.dark,
    );
    final realFontFamily = AppVariables.getFontFamily(fontFamily);

    return ThemeData(
      textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: realFontFamily,
          ),
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.dark,
      ),
      cardTheme: CardThemeData(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
    );
  }
}
