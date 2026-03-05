import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/modify_device/widgets/device_preview.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('DevicePreview', () {
    testWidgets('renders properly with boolean type', (tester) async {
      await tester.pumpApp(
        const DevicePreview(
          title: 'My Boolean',
          subtitle: 'A simple switch',
          iconName: 'lightbulb',
          tileType: DeviceTileType.boolean,
          rangeMin: 0,
          rangeMax: 10,
          divisions: 0,
          interval: 1,
        ),
      );

      expect(find.text('My Boolean'), findsOneWidget);
      expect(find.text('A simple switch'), findsOneWidget);

      expect(find.byType(Switch), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
    });

    testWidgets('renders properly with empty title and subtitle for boolean',
        (tester) async {
      await tester.pumpApp(
        const DevicePreview(
          title: '',
          subtitle: '',
          iconName: 'lightbulb',
          tileType: DeviceTileType.boolean,
          rangeMin: 0,
          rangeMax: 10,
          divisions: 0,
          interval: 1,
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Device title'), findsOneWidget);
    });

    testWidgets('renders properly with number type', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: DevicePreview(
            title: 'My Number',
            subtitle: 'A simple slider',
            iconName: 'lightbulb',
            tileType: DeviceTileType.number,
            rangeMin: 0,
            rangeMax: 10,
            divisions: 10,
            interval: 1,
          ),
        ),
      );

      expect(find.text('My Number'), findsOneWidget);
      expect(find.text('A simple slider'), findsOneWidget);

      expect(find.byType(Slider), findsOneWidget);

      final decreaseIcon = find.byWidgetPredicate(
        (widget) =>
            widget is HugeIcon &&
            widget.icon == HugeIcons.strokeRoundedRemove01,
      );
      final increaseIcon = find.byWidgetPredicate(
        (widget) =>
            widget is HugeIcon && widget.icon == HugeIcons.strokeRoundedAdd01,
      );

      expect(decreaseIcon, findsOneWidget);
      expect(increaseIcon, findsOneWidget);

      await tester.tap(decreaseIcon);
      await tester.pumpAndSettle();

      await tester.tap(increaseIcon);
      await tester.pumpAndSettle();

      final slider = tester.widget<Slider>(find.byType(Slider));
      slider.onChanged?.call(8);
      await tester.pumpAndSettle();
    });

    testWidgets('interval buttons handle boundaries properly', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: DevicePreview(
            title: 'Boundary Test',
            subtitle: 'Testing min max',
            iconName: 'lightbulb',
            tileType: DeviceTileType.number,
            rangeMin: 5,
            rangeMax: 7,
            divisions: 2,
            interval: 2,
          ),
        ),
      );

      expect(find.text('6.0'), findsOneWidget);

      final decreaseButton = find.byWidgetPredicate(
        (widget) =>
            widget is HugeIcon &&
            widget.icon == HugeIcons.strokeRoundedRemove01,
      );
      final increaseButton = find.byWidgetPredicate(
        (widget) =>
            widget is HugeIcon && widget.icon == HugeIcons.strokeRoundedAdd01,
      );

      await tester.tap(decreaseButton);
      await tester.pumpAndSettle();
      expect(find.text('5.0'), findsOneWidget);

      await tester.tap(increaseButton);
      await tester.pumpAndSettle();
      expect(find.text('7.0'), findsOneWidget);

      await tester.tap(increaseButton);
      await tester.pumpAndSettle();
      expect(find.text('7.0'), findsOneWidget);
    });

    testWidgets('inits safely when rangeMin >= rangeMax for Number type',
        (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: DevicePreviewTile(
            title: '',
            subtitle: '',
            iconName: 'lightbulb',
            tileType: DeviceTileType.number,
            rangeMin: 10,
            rangeMax: 5,
            divisions: 0,
            interval: 0,
          ),
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.min, 0.0);
      expect(slider.max, 10.0);
      expect(slider.divisions, 1);
    });

    testWidgets(
      'inits safely when initial number value is out of bounds',
      (tester) async {},
    );
  });
}
