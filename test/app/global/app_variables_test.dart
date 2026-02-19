import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AppVariables', () {
    test('buildGroupTopic formats correctly', () {
      expect(
        AppVariables.buildGroupTopic(
          groupTitle: 'Living Room',
          suffix: 'status',
        ),
        'living-room/status',
      );
    });

    test('buildDeviceTopic formats correctly', () {
      expect(
        AppVariables.buildDeviceTopic(
          groupTitle: 'Living Room',
          deviceTitle: 'Main Light',
          suffix: 'command',
        ),
        'living-room/main-light/command',
      );
    });

    test('text normalization handles accents and spaces', () {
      expect(
        AppVariables.buildGroupTopic(
          groupTitle: 'Área De Baño Pingüino ',
          suffix: 'status',
        ),
        'area-de-bano-pinguino-/status',
      );
    });

    test('availableFonts contains default font', () {
      expect(AppVariables.availableFonts.containsKey('Poppins'), isTrue);
    });

    group('SnackBarType', () {
      test('properties return correct boolean values', () {
        expect(SnackBarType.success.isSuccess, isTrue);
        expect(SnackBarType.success.isError, isFalse);

        expect(SnackBarType.error.isError, isTrue);
        expect(SnackBarType.warning.isWarning, isTrue);
        expect(SnackBarType.info.isInfo, isTrue);
      });
    });
  });
}
