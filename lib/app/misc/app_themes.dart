import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omni_remote/app/app.dart';

class AppThemes {
  static ThemeData lightTheme({required String baseColor}) {
    final color = ColorHelper.getColorByName(baseColor);
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.rubik().fontFamily,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
      ),
    );
  }

  static ThemeData darkTheme({required String baseColor}) {
    final color = ColorHelper.getColorByName(baseColor);
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.rubik().fontFamily,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.dark,
      ),
    );
  }
}
