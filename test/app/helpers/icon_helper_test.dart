import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/helpers/icon_helper.dart';

void main() {
  group('IconHelper', () {
    test('getIconByName returns correct icon for known device name', () {
      final icon = IconHelper.getIconByName('LIGHT');
      expect(icon, HugeIcons.strokeRoundedLamp);
    });

    test('getIconByName returns correct icon for known group name', () {
      final icon = IconHelper.getIconByName('BEDROOM');
      expect(icon, HugeIcons.strokeRoundedBed);
    });

    test('getIconByName is case-insensitive', () {
      final iconUpper = IconHelper.getIconByName('KITCHEN');
      final iconLower = IconHelper.getIconByName('kitchen');
      final iconMixed = IconHelper.getIconByName('kItChEn');

      expect(iconUpper, HugeIcons.strokeRoundedKitchenUtensils);
      expect(iconLower, HugeIcons.strokeRoundedKitchenUtensils);
      expect(iconMixed, HugeIcons.strokeRoundedKitchenUtensils);
    });

    test('getIconByName returns default icon for unknown name', () {
      final icon = IconHelper.getIconByName('UNKNOWN_ICON_NAME');
      expect(icon, HugeIcons.strokeRoundedDeveloper);
    });
  });
}
