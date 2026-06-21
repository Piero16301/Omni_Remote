import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData lightTheme({
    required Color baseColor,
    required String fontFamily,
  }) {
    final colorScheme = ColorScheme.fromSeed(seedColor: baseColor);

    return ThemeData(
      textTheme: ThemeData.light().textTheme
          .apply(fontFamily: fontFamily)
          .applyFontVariations(
            const <FontVariation>[
              FontVariation('ROND', 100),
              FontVariation('wght', 500),
            ],
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
      textTheme: ThemeData.dark().textTheme
          .apply(fontFamily: fontFamily)
          .applyFontVariations(
            const <FontVariation>[
              FontVariation('ROND', 100),
              FontVariation('wght', 500),
            ],
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

extension TextThemeFontVariations on TextTheme {
  TextTheme applyFontVariations(List<FontVariation> fontVariations) {
    return copyWith(
      displayLarge: displayLarge?.copyWith(fontVariations: fontVariations),
      displayMedium: displayMedium?.copyWith(fontVariations: fontVariations),
      displaySmall: displaySmall?.copyWith(fontVariations: fontVariations),
      headlineLarge: headlineLarge?.copyWith(fontVariations: fontVariations),
      headlineMedium: headlineMedium?.copyWith(fontVariations: fontVariations),
      headlineSmall: headlineSmall?.copyWith(fontVariations: fontVariations),
      titleLarge: titleLarge?.copyWith(fontVariations: fontVariations),
      titleMedium: titleMedium?.copyWith(fontVariations: fontVariations),
      titleSmall: titleSmall?.copyWith(fontVariations: fontVariations),
      bodyLarge: bodyLarge?.copyWith(fontVariations: fontVariations),
      bodyMedium: bodyMedium?.copyWith(fontVariations: fontVariations),
      bodySmall: bodySmall?.copyWith(fontVariations: fontVariations),
      labelLarge: labelLarge?.copyWith(fontVariations: fontVariations),
      labelMedium: labelMedium?.copyWith(fontVariations: fontVariations),
      labelSmall: labelSmall?.copyWith(fontVariations: fontVariations),
    );
  }
}
