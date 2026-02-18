import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/app/app.dart';

void main() {
  group('ThemeHelper', () {
    test('getThemeByName returns correct ThemeMode for valid names', () {
      expect(
        ThemeHelper.getThemeByName(ThemeMode.light.name.toUpperCase()),
        ThemeMode.light,
      );
      expect(
        ThemeHelper.getThemeByName(ThemeMode.dark.name.toUpperCase()),
        ThemeMode.dark,
      );
    });

    test('getThemeByName returns default ThemeMode (light) for invalid names',
        () {
      expect(ThemeHelper.getThemeByName('UNKNOWN_THEME'), ThemeMode.light);
      expect(ThemeHelper.getThemeByName(''), ThemeMode.light);
      expect(ThemeHelper.getThemeByName('123'), ThemeMode.light);
    });

    test('getThemeByName is case-insensitive', () {
      expect(ThemeHelper.getThemeByName('light'), ThemeMode.light);
      expect(ThemeHelper.getThemeByName('dark'), ThemeMode.dark);
    });

    group('getThemeName', () {
      test('returns correct string for ThemeMode.light', () {
        expect(ThemeHelper.getThemeName(ThemeMode.light), 'LIGHT');
      });

      test('returns correct string for ThemeMode.dark', () {
        expect(ThemeHelper.getThemeName(ThemeMode.dark), 'DARK');
      });

      test('returns correct string for ThemeMode.system', () {
        expect(ThemeHelper.getThemeName(ThemeMode.system), 'SYSTEM');
      });
    });
  });
}
