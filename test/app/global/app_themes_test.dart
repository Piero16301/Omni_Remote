import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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

      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
    });

    test('darkTheme generates dark ThemeData', () {
      final theme = AppThemes.darkTheme(
        baseColor: Colors.red,
        fontFamily: 'Arial',
      );

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);

      expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
    });
  });
}
