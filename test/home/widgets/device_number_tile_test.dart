import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/home/home.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:typed_data/typed_data.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockMqttService extends Mock implements MqttService {}

class MockMqttServerClient extends Mock implements MqttServerClient {}

class MockMqttClientConnectionStatus extends Mock
    implements MqttClientConnectionStatus {}

class FakeUint8Buffer extends Fake implements Uint8Buffer {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUint8Buffer());
    registerFallbackValue(MqttQos.atLeastOnce);
  });

  group('DeviceNumberTile', () {
    late AppCubit appCubit;
    late MqttService mockMqttService;
    late MqttServerClient mockMqttClient;
    late MqttClientConnectionStatus mockConnectionStatus;
    late StreamController<List<MqttReceivedMessage<MqttMessage>>>
        messageController;

    final testGroup = GroupModel(
      id: 'g1',
      title: 'Living Room',
      subtitle: '',
      icon: '',
    );
    final testDevice = DeviceModel(
      id: 'd1',
      title: 'Thermostat',
      subtitle: 'Main',
      icon: 'thermostat',
      tileType: DeviceTileType.number,
      groupId: 'g1',
      rangeMin: 16,
      rangeMax: 30,
      divisions: 14,
      interval: 1,
    );

    setUp(() async {
      appCubit = MockAppCubit();
      mockMqttService = MockMqttService();
      mockMqttClient = MockMqttServerClient();
      mockConnectionStatus = MockMqttClientConnectionStatus();
      messageController =
          StreamController<List<MqttReceivedMessage<MqttMessage>>>.broadcast();

      when(() => mockConnectionStatus.state)
          .thenReturn(MqttConnectionState.connected);
      when(() => mockMqttClient.connectionStatus)
          .thenReturn(mockConnectionStatus);
      when(() => mockMqttClient.subscribe(any(), any())).thenReturn(null);
      when(() => mockMqttClient.unsubscribe(any())).thenAnswer((_) {});
      when(() => mockMqttClient.publishMessage(any(), any(), any()))
          .thenReturn(1);

      when(() => mockMqttService.mqttClient).thenReturn(mockMqttClient);
      when(() => mockMqttService.messageStream)
          .thenAnswer((_) => messageController.stream);

      if (!getIt.isRegistered<MqttService>()) {
        getIt.registerSingleton<MqttService>(mockMqttService);
      } else {
        await getIt.unregister<MqttService>();
        getIt.registerSingleton<MqttService>(mockMqttService);
      }

      when(() => appCubit.state).thenReturn(
        const AppState(
          brokerConnectionStatus: BrokerConnectionStatus.connected,
        ),
      );
    });

    tearDown(() {
      unawaited(messageController.close());
      unawaited(getIt.reset());
    });

    Widget buildSubject({
      bool groupIsOnline = true,
      void Function()? onEdit,
      void Function()? onDelete,
    }) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: appCubit),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DeviceNumberTile(
              device: testDevice,
              group: testGroup,
              groupIsOnline: groupIsOnline,
              onEdit: onEdit ?? () {},
              onDelete: onDelete ?? () {},
            ),
          ),
        ),
      );
    }

    testWidgets('renders device details correctly', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Thermostat'), findsOneWidget);
      expect(find.text('Main'), findsOneWidget);
      expect(find.text('16.0'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('subscribes to MQTT topic on load', (tester) async {
      await tester.pumpWidget(buildSubject());

      final expectedTopic = AppVariables.buildDeviceTopic(
        groupTitle: testGroup.title,
        deviceTitle: testDevice.title,
        suffix: AppVariables.statusSuffix,
      );

      verify(
        () => mockMqttClient.subscribe(expectedTopic, MqttQos.atMostOnce),
      ).called(1);
    });

    testWidgets('publishes MQTT message when increased', (tester) async {
      await tester.pumpWidget(buildSubject());

      final expectedTopic = AppVariables.buildDeviceTopic(
        groupTitle: testGroup.title,
        deviceTitle: testDevice.title,
        suffix: AppVariables.commandSuffix,
      );

      final iconButtons = find.byType(IconButton);

      await tester.tap(iconButtons.last);
      await tester.pumpAndSettle();

      verify(
        () => mockMqttClient.publishMessage(
          expectedTopic,
          MqttQos.atLeastOnce,
          any(),
        ),
      ).called(1);
    });

    testWidgets('shows device options on long press', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.longPress(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('Thermostat'), findsNWidgets(2));
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('calls onEdit when Edit is tapped', (tester) async {
      var editCalled = false;
      await tester.pumpWidget(
        buildSubject(
          onEdit: () => editCalled = true,
        ),
      );

      await tester.longPress(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      expect(editCalled, isTrue);
    });

    testWidgets('calls onDelete when Delete confirmation is accepted',
        (tester) async {
      var deleteCalled = false;
      await tester.pumpWidget(
        buildSubject(
          onDelete: () => deleteCalled = true,
        ),
      );

      await tester.longPress(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AppFilledButton));
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
    });
  });
}
