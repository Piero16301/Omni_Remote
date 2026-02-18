import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/app/helpers/color_helper.dart';

void main() {
  group('ColorHelper', () {
    test('getColorByName returns correct color for valid uppercase names', () {
      expect(ColorHelper.getColorByName('RED'), Colors.red);
      expect(ColorHelper.getColorByName('BLUE'), Colors.blue);
      expect(ColorHelper.getColorByName('GREEN'), Colors.green);
      expect(ColorHelper.getColorByName('YELLOW'), Colors.yellow);
      expect(ColorHelper.getColorByName('DEEP_PURPLE'), Colors.deepPurple);
      expect(ColorHelper.getColorByName('BLUE_GREY'), Colors.blueGrey);
    });

    test(
        'getColorByName returns correct color for valid lowercase or '
        'mixed-case names', () {
      expect(ColorHelper.getColorByName('red'), Colors.red);
      expect(ColorHelper.getColorByName('Blue'), Colors.blue);
      expect(ColorHelper.getColorByName('gReEn'), Colors.green);
      expect(ColorHelper.getColorByName('deep_purple'), Colors.deepPurple);
    });

    test('getColorByName returns default color (Green) for invalid names', () {
      expect(ColorHelper.getColorByName('NON_EXISTENT_COLOR'), Colors.green);
      expect(
        ColorHelper.getColorByName('magenta'),
        Colors.green,
      );
      expect(ColorHelper.getColorByName(''), Colors.green);
      expect(ColorHelper.getColorByName('123'), Colors.green);
    });

    group('getColorName', () {
      test('returns correct name for valid colors', () {
        expect(ColorHelper.getColorName(Colors.red), 'RED');
        expect(ColorHelper.getColorName(Colors.blue), 'BLUE');
        expect(ColorHelper.getColorName(Colors.green), 'GREEN');
        expect(ColorHelper.getColorName(Colors.yellow), 'YELLOW');
        expect(ColorHelper.getColorName(Colors.deepPurple), 'DEEP_PURPLE');
        expect(ColorHelper.getColorName(Colors.blueGrey), 'BLUE_GREY');
      });

      test('throws StateError for colors not in the map', () {
        expect(
          () => ColorHelper.getColorName(const Color(0xFF000000)), // Black
          throwsStateError,
        );
        expect(
          () => ColorHelper.getColorName(Colors.white),
          throwsStateError,
        );
      });
    });
  });
}
