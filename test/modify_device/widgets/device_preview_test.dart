import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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

      expect(find.byType(ExpressiveSwitch), findsOneWidget);

      await tester.tap(find.byType(ExpressiveSwitch));
      await tester.pumpAndSettle();
    });

    testWidgets('renders properly with empty title and subtitle for boolean', (
      tester,
    ) async {
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

      expect(find.byType(ExpressiveSwitch), findsOneWidget);
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

      expect(find.byType(ExpressiveSlider), findsOneWidget);

      final slider = tester.widget<ExpressiveSlider>(
        find.byType(ExpressiveSlider),
      );
      slider.onChanged?.call(8);
      await tester.pumpAndSettle();
      expect(find.text('8.0'), findsOneWidget);
    });

    testWidgets('inits safely when rangeMin >= rangeMax for Number type', (
      tester,
    ) async {
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

      final slider = tester.widget<ExpressiveSlider>(
        find.byType(ExpressiveSlider),
      );
      expect(slider.min, 0.0);
      expect(slider.max, 10.0);
      expect(slider.divisions, 1);
    });

    testWidgets(
      'transitions safely from boolean to number with default range values',
      (tester) async {
        var tileType = DeviceTileType.boolean;
        await tester.pumpApp(
          StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    DevicePreview(
                      title: '',
                      subtitle: '',
                      iconName: 'LIGHT',
                      tileType: tileType,
                      rangeMin: 0,
                      rangeMax: 0,
                      divisions: 0,
                      interval: 0,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          tileType = DeviceTileType.number;
                        });
                      },
                      child: const Text('Switch to number'),
                    ),
                  ],
                ),
              );
            },
          ),
        );

        expect(find.byType(ExpressiveSwitch), findsOneWidget);
        await tester.tap(find.text('Switch to number'));
        await tester.pumpAndSettle();

        expect(find.byType(ExpressiveSlider), findsOneWidget);
      },
    );

    testWidgets(
      'inits safely when initial number value is out of bounds',
      (tester) async {},
    );
  });
}
