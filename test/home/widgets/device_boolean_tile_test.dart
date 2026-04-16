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

  group('DeviceBooleanTile', () {
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
      title: 'Light',
      subtitle: 'Main',
      icon: 'lightbulb',
      tileType: DeviceTileType.boolean,
      groupId: 'g1',
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

      await getIt.reset();
      setupServiceLocator(Environment.mock);
      getIt
        ..unregister<MqttService>()
        ..registerSingleton<MqttService>(mockMqttService);

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
            body: DeviceBooleanTile(
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

      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Main'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('subscribes to MQTT topic on load', (tester) async {
      await tester.pumpWidget(buildSubject());

      final expectedTopic = AppVariables.buildDeviceTopic(
        groupTitle: testGroup.title,
        deviceTitle: testDevice.title,
        suffix: AppVariables.statusSuffix,
      );

      verify(
        () => mockMqttClient.subscribe(expectedTopic, MqttQos.atLeastOnce),
      ).called(1);
    });

    testWidgets('publishes MQTT message when toggled', (tester) async {
      await tester.pumpWidget(buildSubject());

      final expectedTopic = AppVariables.buildDeviceTopic(
        groupTitle: testGroup.title,
        deviceTitle: testDevice.title,
        suffix: AppVariables.commandSuffix,
      );

      final switchWidget = find.byType(Switch);
      await tester.tap(switchWidget);
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

      await tester.longPress(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('Light'), findsNWidgets(2));

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('calls onEdit when Edit is tapped', (tester) async {
      var editCalled = false;
      await tester.pumpWidget(
        buildSubject(
          onEdit: () => editCalled = true,
        ),
      );

      await tester.longPress(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      expect(editCalled, isTrue);
    });

    testWidgets('shows delete confirmation when Delete is tapped',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.longPress(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).last);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('calls onDelete when Delete confirmation is accepted',
        (tester) async {
      var deleteCalled = false;
      await tester.pumpWidget(
        buildSubject(
          onDelete: () => deleteCalled = true,
        ),
      );

      await tester.longPress(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AppFilledButton));
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
    });

    testWidgets('cancel button in delete dialog closes it', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.longPress(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).last);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.byType(AppOutlinedButton));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Switch is disabled when groupIsOnline is false',
        (tester) async {
      await tester.pumpWidget(buildSubject(groupIsOnline: false));

      final sw = tester.widget<Switch>(find.byType(Switch));
      expect(sw.onChanged, isNull);
    });

    testWidgets('does not subscribe when mqttClient is null', (tester) async {
      when(() => mockMqttService.mqttClient).thenReturn(null);

      await tester.pumpWidget(buildSubject());

      verifyNever(() => mockMqttClient.subscribe(any(), any()));
    });

    testWidgets('does not publish when mqttClient is null on toggle',
        (tester) async {
      when(() => mockConnectionStatus.state)
          .thenReturn(MqttConnectionState.disconnected);

      await tester.pumpWidget(buildSubject());

      when(() => mockMqttService.mqttClient).thenReturn(null);

      final sw = find.byType(Switch);

      expect(sw, findsOneWidget);
    });

    testWidgets('device without subtitle does not show subtitle text',
        (tester) async {
      final deviceNoSub = DeviceModel(
        id: 'd2',
        title: 'Fan',
        subtitle: '',
        icon: 'fan',
        tileType: DeviceTileType.boolean,
        groupId: 'g1',
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [BlocProvider.value(value: appCubit)],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: DeviceBooleanTile(
                device: deviceNoSub,
                group: testGroup,
                groupIsOnline: true,
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Fan'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('BlocListener handles disconnect state', (tester) async {
      final stateController = StreamController<AppState>.broadcast();
      when(() => appCubit.stream).thenAnswer((_) => stateController.stream);

      await tester.pumpWidget(buildSubject());

      when(() => appCubit.state).thenReturn(
        const AppState(),
      );
      stateController.add(
        const AppState(),
      );
      await tester.pump();

      when(() => appCubit.state).thenReturn(
        const AppState(
          brokerConnectionStatus: BrokerConnectionStatus.connected,
        ),
      );
      stateController.add(
        const AppState(
          brokerConnectionStatus: BrokerConnectionStatus.connected,
        ),
      );
      await tester.pump();

      await stateController.close();
    });

    testWidgets('updates state when MQTT message is received', (tester) async {
      await tester.pumpWidget(buildSubject());

      final statusTopic = AppVariables.buildDeviceTopic(
        groupTitle: testGroup.title,
        deviceTitle: testDevice.title,
        suffix: AppVariables.statusSuffix,
      );

      final builder = MqttClientPayloadBuilder()..addString('1');
      final publishMessage = MqttPublishMessage()
        ..payload.message = builder.payload!;

      final receivedMessage = MqttReceivedMessage<MqttMessage>(
        statusTopic,
        publishMessage,
      );

      messageController.add([receivedMessage]);
      await tester.pump();

      final sw = tester.widget<Switch>(find.byType(Switch));
      expect(sw.value, isTrue);
    });
  });
}
