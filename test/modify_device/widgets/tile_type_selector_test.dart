import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/modify_device/widgets/tile_type_selector.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('TileTypeSelector', () {
    testWidgets('renders properly with boolean selected', (tester) async {
      DeviceTileType? selectedType;

      await tester.pumpApp(
        TileTypeSelector(
          selectedType: DeviceTileType.boolean,
          onTypeSelected: (type) {
            selectedType = type;
          },
        ),
      );

      expect(find.byType(SegmentedButton<DeviceTileType>), findsOneWidget);
      expect(find.text('Boolean'), findsOneWidget);
      expect(find.text('Number'), findsOneWidget);

      await tester.tap(find.text('Number'));
      await tester.pumpAndSettle();

      expect(selectedType, DeviceTileType.number);
    });

    testWidgets('renders properly with number selected', (tester) async {
      DeviceTileType? selectedType;

      await tester.pumpApp(
        TileTypeSelector(
          selectedType: DeviceTileType.number,
          onTypeSelected: (type) {
            selectedType = type;
          },
        ),
      );

      expect(find.byType(SegmentedButton<DeviceTileType>), findsOneWidget);

      await tester.tap(find.text('Boolean'));
      await tester.pumpAndSettle();

      expect(selectedType, DeviceTileType.boolean);
    });
  });
}
