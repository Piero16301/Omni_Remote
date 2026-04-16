import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/home/home.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:typed_data/typed_data.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

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

  group('GroupCard', () {
    late AppCubit appCubit;
    late HomeCubit homeCubit;
    late MqttService mockMqttService;
    late MqttServerClient mockMqttClient;
    late MqttClientConnectionStatus mockConnectionStatus;
    late StreamController<List<MqttReceivedMessage<MqttMessage>>>
        messageController;
    late ValueNotifier<List<DeviceModel>> devicesNotifier;

    final testGroup = GroupModel(
      id: 'g1',
      title: 'Living Room',
      subtitle: 'Main area',
      icon: 'sofa',
    );

    setUp(() async {
      appCubit = MockAppCubit();
      homeCubit = MockHomeCubit();
      mockMqttService = MockMqttService();
      mockMqttClient = MockMqttServerClient();
      mockConnectionStatus = MockMqttClientConnectionStatus();
      messageController =
          StreamController<List<MqttReceivedMessage<MqttMessage>>>.broadcast();
      devicesNotifier = ValueNotifier<List<DeviceModel>>([]);

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

      when(() => homeCubit.getDevicesListenable()).thenReturn(devicesNotifier);
    });

    tearDown(() {
      unawaited(messageController.close());
      unawaited(getIt.reset());
    });

    Widget buildSubject({
      void Function()? onEdit,
      void Function()? onDelete,
    }) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: appCubit),
          BlocProvider.value(value: homeCubit),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: GroupCard(
              group: testGroup,
              onEdit: onEdit ?? () {},
              onDelete: onDelete ?? () {},
            ),
          ),
        ),
      );
    }

    testWidgets('renders group details correctly without devices',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Living Room'), findsOneWidget);
      expect(find.text('Main area'), findsOneWidget);
      expect(find.text('No devices in this group'), findsOneWidget);
      expect(find.byType(HugeIcon), findsWidgets);
    });

    testWidgets('renders device tiles when devices exist', (tester) async {
      final testDevice = DeviceModel(
        id: 'd1',
        title: 'Light 1',
        subtitle: '',
        icon: 'lightbulb',
        tileType: DeviceTileType.boolean,
        groupId: testGroup.id,
      );
      devicesNotifier.value = [testDevice];

      await tester.pumpWidget(buildSubject());

      expect(find.text('Living Room'), findsOneWidget);
      expect(find.text('Light 1'), findsOneWidget);
      expect(find.byType(DeviceBooleanTile), findsOneWidget);
    });

    testWidgets('subscribes to group online MQTT topic', (tester) async {
      await tester.pumpWidget(buildSubject());

      final expectedTopic = AppVariables.buildGroupTopic(
        groupTitle: testGroup.title,
        suffix: AppVariables.onlineSuffix,
      );

      verify(() => mockMqttClient.subscribe(expectedTopic, MqttQos.atLeastOnce))
          .called(1);
    });

    testWidgets('shows group options on long press', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.longPress(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('Living Room'), findsNWidgets(2));
      expect(
        find.byType(ListTile),
        findsNWidgets(3),
      );
    });

    testWidgets('calls onEdit when Edit is tapped', (tester) async {
      var editCalled = false;
      await tester.pumpWidget(
        buildSubject(onEdit: () => editCalled = true),
      );

      await tester.longPress(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).at(1));
      await tester.pumpAndSettle();

      expect(editCalled, isTrue);
    });

    testWidgets('calls onDelete when Delete is confirmed', (tester) async {
      var deleteCalled = false;
      await tester.pumpWidget(
        buildSubject(onDelete: () => deleteCalled = true),
      );

      await tester.longPress(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AppFilledButton));
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
    });

    testWidgets('cancel button in delete dialog closes it', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.longPress(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).last);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.byType(AppOutlinedButton));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('reconnect option in bottom sheet calls _verifyStatus',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.longPress(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      final expectedTopic = AppVariables.buildGroupTopic(
        groupTitle: testGroup.title,
        suffix: AppVariables.onlineSuffix,
      );
      verify(() => mockMqttClient.unsubscribe(expectedTopic)).called(1);
    });

    testWidgets('renders DeviceNumberTile for number type devices',
        (tester) async {
      final numberDevice = DeviceModel(
        id: 'd2',
        title: 'Thermostat',
        subtitle: '',
        icon: 'thermometer',
        tileType: DeviceTileType.number,
        groupId: testGroup.id,
        rangeMin: 16,
        rangeMax: 30,
        divisions: 14,
        interval: 1,
      );
      devicesNotifier.value = [numberDevice];

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: appCubit),
            BlocProvider.value(value: homeCubit),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SizedBox(
                height: 600,
                child: GroupCard(
                  group: testGroup,
                  onEdit: () {},
                  onDelete: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DeviceNumberTile), findsOneWidget);
    });

    testWidgets('does not subscribe when mqttClient is null', (tester) async {
      when(() => mockMqttService.mqttClient).thenReturn(null);

      await tester.pumpWidget(buildSubject());

      verifyNever(() => mockMqttClient.subscribe(any(), any()));
    });

    testWidgets('updates _isOnline when MQTT online message is received',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      final onlineTopic = AppVariables.buildGroupTopic(
        groupTitle: testGroup.title,
        suffix: AppVariables.onlineSuffix,
      );

      final builder = MqttClientPayloadBuilder()..addString('1');
      final publishMessage = MqttPublishMessage()
        ..payload.message = builder.payload!;

      final receivedMessage = MqttReceivedMessage<MqttMessage>(
        onlineTopic,
        publishMessage,
      );

      messageController.add([receivedMessage]);
      await tester.pump();

      expect(find.byType(GroupCard), findsOneWidget);
    });

    testWidgets('group with subtitle renders subtitle text', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Main area'), findsOneWidget);
    });

    testWidgets('group without subtitle does not show subtitle',
        (tester) async {
      final groupNoSub = GroupModel(
        id: 'g2',
        title: 'Bedroom',
        subtitle: '',
        icon: 'settings',
      );

      when(() => homeCubit.getDevicesListenable())
          .thenReturn(ValueNotifier([]));

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: appCubit),
            BlocProvider.value(value: homeCubit),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: GroupCard(
                group: groupNoSub,
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Bedroom'), findsOneWidget);
      expect(find.text(''), findsNothing);
    });
  });
}
