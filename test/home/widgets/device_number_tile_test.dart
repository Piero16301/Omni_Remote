import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' hide ConnectionState;
import 'package:mocktail/mocktail.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/home/home.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:typed_data/typed_data.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit;

class MockMqttService extends Mock implements MqttService;

class MockMqttServerClient extends Mock implements MqttServerClient;

class MockMqttClientConnectionStatus extends Mock
    implements MqttClientConnectionStatus;

class MockAnalyticsService extends Mock implements AnalyticsService;

class MockCrashService extends Mock implements CrashService;

class FakeMqttMessage extends Fake implements MqttMessage;

class FakeUint8Buffer extends Fake implements Uint8Buffer;

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUint8Buffer());
    registerFallbackValue(MqttQos.atLeastOnce);
    registerFallbackValue(StackTrace.current);
  });

  group('DeviceNumberTile', () {
    late AppCubit appCubit;
    late MqttService mockMqttService;
    late MqttServerClient mockMqttClient;
    late MqttClientConnectionStatus mockConnectionStatus;
    late AnalyticsService mockAnalyticsService;
    late CrashService mockCrashService;
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
      mockAnalyticsService = MockAnalyticsService();
      mockCrashService = MockCrashService();
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
      await getIt.unregister<MqttService>();
      getIt.registerSingleton<MqttService>(mockMqttService);
      await getIt.unregister<AnalyticsService>();
      getIt.registerSingleton<AnalyticsService>(mockAnalyticsService);
      await getIt.unregister<CrashService>();
      getIt.registerSingleton<CrashService>(mockCrashService);

      when(
        () => mockAnalyticsService.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenReturn(null);
      when(
        () => mockCrashService.recordError(
          any<dynamic>(),
          any<StackTrace?>(),
          reason: any<String>(named: 'reason'),
        ),
      ).thenReturn(null);

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
        providers: [BlocProvider.value(value: appCubit)],
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
      expect(find.byType(ExpressiveSlider), findsOneWidget);
    });

    testWidgets('subscribes to MQTT topic on load', (tester) async {
      await tester.pumpWidget(buildSubject());

      final expectedTopic = AppVariables.buildDeviceTopic(
        groupTitle: testGroup.title,
        deviceTitle: testDevice.title,
        suffix: AppVariables.statusSuffix,
      );

      verify(() => mockMqttClient.subscribe(expectedTopic, MqttQos.atMostOnce))
          .called(1);
    });

    testWidgets('publishes MQTT message when slider changes', (tester) async {
      await tester.pumpWidget(buildSubject());

      final expectedTopic = AppVariables.buildDeviceTopic(
        groupTitle: testGroup.title,
        deviceTitle: testDevice.title,
        suffix: AppVariables.commandSuffix,
      );

      final slider = tester.widget<ExpressiveSlider>(
        find.byType(ExpressiveSlider),
      );
      slider.onChangeEnd?.call(20);
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
      await tester.pumpWidget(buildSubject(onEdit: () => editCalled = true));

      await tester.longPress(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      expect(editCalled, isTrue);
    });

    testWidgets('calls onDelete when Delete confirmation is accepted', (
      tester,
    ) async {
      var deleteCalled = false;
      await tester.pumpWidget(
        buildSubject(onDelete: () => deleteCalled = true),
      );

      await tester.longPress(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).last);
      await tester.pumpAndSettle();

      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is ExpressiveButton &&
              w.variant == ExpressiveButtonVariant.filled,
        ),
      );
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
    });

    testWidgets('cancel button in delete dialog closes it', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.longPress(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).last);
      await tester.pumpAndSettle();

      expect(find.byType(ExpressiveAlertDialog), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is ExpressiveButton &&
              w.variant == ExpressiveButtonVariant.outlined,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExpressiveAlertDialog), findsNothing);
    });

    testWidgets('increment button is disabled when groupIsOnline is false', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(groupIsOnline: false));

      final slider = tester.widget<ExpressiveSlider>(
        find.byType(ExpressiveSlider),
      );
      expect(slider.onChanged, isNull);
      expect(slider.onChangeEnd, isNull);
    });

    testWidgets('does not subscribe when mqttClient is null', (tester) async {
      when(() => mockMqttService.mqttClient).thenReturn(null);

      await tester.pumpWidget(buildSubject());

      verifyNever(() => mockMqttClient.subscribe(any(), any()));
    });

    testWidgets('device without subtitle renders without subtitle', (
      tester,
    ) async {
      final deviceNoSub = DeviceModel(
        id: 'd2',
        title: 'Heater',
        subtitle: '',
        icon: 'fire',
        tileType: DeviceTileType.number,
        groupId: 'g1',
        rangeMax: 100,
        divisions: 10,
        interval: 10,
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [BlocProvider.value(value: appCubit)],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: DeviceNumberTile(
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

      expect(find.text('Heater'), findsOneWidget);
      expect(find.byType(ExpressiveSlider), findsOneWidget);
    });

    testWidgets('BlocListener handles disconnect state', (tester) async {
      final stateController = StreamController<AppState>.broadcast();
      when(() => appCubit.stream).thenAnswer((_) => stateController.stream);

      await tester.pumpWidget(buildSubject());

      when(() => appCubit.state).thenReturn(const AppState());
      stateController.add(const AppState());
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

    testWidgets('updates slider value when MQTT numeric message is received', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      final statusTopic = AppVariables.buildDeviceTopic(
        groupTitle: testGroup.title,
        deviceTitle: testDevice.title,
        suffix: AppVariables.statusSuffix,
      );

      final builder = MqttClientPayloadBuilder()..addString('22.5');
      final publishMessage = MqttPublishMessage()
        ..payload.message = builder.payload!;

      messageController.add([
        MqttReceivedMessage<MqttMessage>(statusTopic, publishMessage),
      ]);
      await tester.pump();

      expect(find.text('22.5'), findsOneWidget);
    });

    testWidgets('logs analytics event when command is published', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      final slider = tester.widget<ExpressiveSlider>(
        find.byType(ExpressiveSlider),
      );
      slider.onChangeEnd?.call(17);
      await tester.pumpAndSettle();

      verify(
        () => mockAnalyticsService.logEvent(
          name: 'device_action_number',
          parameters: {'device_id': testDevice.id, 'value': '17.0'},
        ),
      ).called(1);
    });

    testWidgets('Slider onChanged updates value and onChangeEnd publishes', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      final sliderFinder = find.byType(ExpressiveSlider);
      final slider = tester.widget<ExpressiveSlider>(sliderFinder);

      slider.onChanged!(20);
      await tester.pump();
      expect(find.text('20.0'), findsOneWidget);

      slider.onChangeEnd!(20);
      await tester.pump();

      final expectedTopic = AppVariables.buildDeviceTopic(
        groupTitle: testGroup.title,
        deviceTitle: testDevice.title,
        suffix: AppVariables.commandSuffix,
      );

      verify(
        () => mockMqttClient.publishMessage(
          expectedTopic,
          MqttQos.atLeastOnce,
          any(),
        ),
      ).called(1);
    });

    testWidgets('ignores non-numeric MQTT payload', (tester) async {
      await tester.pumpWidget(buildSubject());

      final statusTopic = AppVariables.buildDeviceTopic(
        groupTitle: testGroup.title,
        deviceTitle: testDevice.title,
        suffix: AppVariables.statusSuffix,
      );

      final builder = MqttClientPayloadBuilder()..addString('not_a_number');
      final publishMessage = MqttPublishMessage()
        ..payload.message = builder.payload!;

      messageController.add([
        MqttReceivedMessage<MqttMessage>(statusTopic, publishMessage),
      ]);
      await tester.pump();

      expect(find.text('16.0'), findsOneWidget);
    });

    testWidgets('ignores MQTT messages for different topics', (tester) async {
      await tester.pumpWidget(buildSubject());

      final builder = MqttClientPayloadBuilder()..addString('25.0');
      final publishMessage = MqttPublishMessage()
        ..payload.message = builder.payload!;

      messageController.add([
        MqttReceivedMessage<MqttMessage>('other/topic', publishMessage),
      ]);
      await tester.pump();

      expect(find.text('16.0'), findsOneWidget);
    });

    testWidgets('records crash error when MQTT payload is invalid', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      final statusTopic = AppVariables.buildDeviceTopic(
        groupTitle: testGroup.title,
        deviceTitle: testDevice.title,
        suffix: AppVariables.statusSuffix,
      );

      messageController.add([
        MqttReceivedMessage<MqttMessage>(statusTopic, FakeMqttMessage()),
      ]);
      await tester.pump();

      verify(
        () => mockCrashService.recordError(
          any<dynamic>(),
          any<StackTrace?>(),
          reason: 'Failed to parse MQTT number device status payload',
        ),
      ).called(1);
    });

    testWidgets('didUpdateWidget verifies status when device changes', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      final updatedDevice = testDevice.copyWith(title: 'Updated Thermostat');
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [BlocProvider.value(value: appCubit)],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: DeviceNumberTile(
                device: updatedDevice,
                group: testGroup,
                groupIsOnline: true,
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final newTopic = AppVariables.buildDeviceTopic(
        groupTitle: testGroup.title,
        deviceTitle: updatedDevice.title,
        suffix: AppVariables.statusSuffix,
      );

      verify(() => mockMqttClient.unsubscribe(newTopic)).called(1);
      verify(
        () => mockAnalyticsService.logEvent(
          name: 'verify_device_status',
          parameters: {'device_id': updatedDevice.id, 'tile_type': 'number'},
        ),
      ).called(1);
      verify(() => mockMqttClient.subscribe(newTopic, MqttQos.atMostOnce))
          .called(1);
    });

    testWidgets('didUpdateWidget skips verifyStatus when disconnected', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      when(() => mockConnectionStatus.state)
          .thenReturn(MqttConnectionState.disconnected);

      final updatedDevice = testDevice.copyWith(title: 'Updated Thermostat');
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [BlocProvider.value(value: appCubit)],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: DeviceNumberTile(
                device: updatedDevice,
                group: testGroup,
                groupIsOnline: true,
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      verifyNever(() => mockMqttClient.unsubscribe(any()));
      verifyNever(
        () => mockAnalyticsService.logEvent(
          name: 'verify_device_status',
          parameters: any(named: 'parameters'),
        ),
      );
    });
  });
}
