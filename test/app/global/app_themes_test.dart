import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AppThemes', () {
    test('lightTheme generates light ThemeData', () {
      final theme = AppThemes.lightTheme(
        baseColor: Colors.blue,
        fontFamily: 'Roboto',
      );

      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
      // The theme should apply the border radius requested to cards
      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
    });

    test('darkTheme generates dark ThemeData', () {
      final theme = AppThemes.darkTheme(
        baseColor: Colors.red,
        fontFamily: 'Arial',
      );

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      // Ensure input decorations have outline border
      expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
    });
  });
}
