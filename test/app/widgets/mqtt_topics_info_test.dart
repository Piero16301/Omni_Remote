import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';

void main() {
  group('MqttTopicsInfo', () {
    Widget buildSubject({
      required TopicInfoType topicInfoType,
      String? groupTitle,
      String? deviceTitle,
      DeviceTileType? deviceTileType,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MqttTopicsInfo(
            topicInfoType: topicInfoType,
            groupTitle: groupTitle,
            deviceTitle: deviceTitle,
            deviceTileType: deviceTileType,
          ),
        ),
      );
    }

    testWidgets('renders empty when groupTitle is null for group type',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(
          topicInfoType: TopicInfoType.group,
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('renders group topics info correctly', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          topicInfoType: TopicInfoType.group,
          groupTitle: 'Living Room',
        ),
      );

      await tester.pumpAndSettle();

      final expectedTopic = AppVariables.buildGroupTopic(
        groupTitle: 'Living Room',
        suffix: AppVariables.onlineSuffix,
      );

      expect(find.text(expectedTopic), findsOneWidget);
      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('renders empty when missing parameters for device type',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(
          topicInfoType: TopicInfoType.device,
          groupTitle: 'Living Room',
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('renders bool device topics info correctly', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          topicInfoType: TopicInfoType.device,
          groupTitle: 'Living Room',
          deviceTitle: 'Light',
          deviceTileType: DeviceTileType.boolean,
        ),
      );

      await tester.pumpAndSettle();

      final statusTopic = AppVariables.buildDeviceTopic(
        groupTitle: 'Living Room',
        deviceTitle: 'Light',
        suffix: AppVariables.statusSuffix,
      );
      final commandTopic = AppVariables.buildDeviceTopic(
        groupTitle: 'Living Room',
        deviceTitle: 'Light',
        suffix: AppVariables.commandSuffix,
      );

      expect(find.text(statusTopic), findsOneWidget);
      expect(find.text(commandTopic), findsOneWidget);
      expect(find.byType(IconButton), findsNWidgets(2));
    });

    testWidgets('renders number device topics info correctly', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          topicInfoType: TopicInfoType.device,
          groupTitle: 'Living Room',
          deviceTitle: 'Thermostat',
          deviceTileType: DeviceTileType.number,
        ),
      );

      await tester.pumpAndSettle();

      final statusTopic = AppVariables.buildDeviceTopic(
        groupTitle: 'Living Room',
        deviceTitle: 'Thermostat',
        suffix: AppVariables.statusSuffix,
      );
      final commandTopic = AppVariables.buildDeviceTopic(
        groupTitle: 'Living Room',
        deviceTitle: 'Thermostat',
        suffix: AppVariables.commandSuffix,
      );

      expect(find.text(statusTopic), findsOneWidget);
      expect(find.text(commandTopic), findsOneWidget);
      expect(find.byType(IconButton), findsNWidgets(2));
    });

    testWidgets('copies topic to clipboard and shows snackbar on tap',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(
          topicInfoType: TopicInfoType.group,
          groupTitle: 'Living Room',
        ),
      );

      await tester.pumpAndSettle();

      final copyButton = find.byType(IconButton).first;
      await tester.tap(copyButton);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
