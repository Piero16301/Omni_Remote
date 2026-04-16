import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:omni_remote/app/app.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockCrashService extends Mock implements CrashService {}

class MockPerformanceService extends Mock implements PerformanceService {}

class MockTrace extends Mock implements Trace {}

class MockMqttServerClient extends Mock implements MqttServerClient {}

class MockMqttClientConnectionStatus extends Mock
    implements MqttClientConnectionStatus {}

void main() {
  late LocalStorageService localStorageService;
  late CrashService crashService;
  late PerformanceService performanceService;
  late MockMqttServerClient mqttClient;
  late MockMqttClientConnectionStatus connectionStatus;
  late ServerMqttRepository repository;
  late Trace trace;

  setUpAll(() {
    registerFallbackValue(StackTrace.current);
  });

  setUp(() async {
    localStorageService = MockLocalStorageService();
    crashService = MockCrashService();
    performanceService = MockPerformanceService();
    mqttClient = MockMqttServerClient();
    connectionStatus = MockMqttClientConnectionStatus();
    trace = MockTrace();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<LocalStorageService>()) {
      await getIt.unregister<LocalStorageService>();
    }
    if (getIt.isRegistered<CrashService>()) {
      getIt.unregister<CrashService>();
    }
    if (getIt.isRegistered<PerformanceService>()) {
      getIt.unregister<PerformanceService>();
    }

    getIt
      ..registerSingleton<LocalStorageService>(localStorageService)
      ..registerSingleton<CrashService>(crashService)
      ..registerSingleton<PerformanceService>(performanceService);

    when(() => performanceService.startTrace(any<String>())).thenReturn(trace);
    when(() => trace.stop()).thenAnswer((_) async {});

    when(() => mqttClient.connectionStatus).thenReturn(connectionStatus);
    when(() => mqttClient.connect(any<String?>(), any<String?>()))
        .thenAnswer((_) async => connectionStatus);
    when(() => mqttClient.disconnect()).thenAnswer((_) {});

    repository = ServerMqttRepository(
      mqttClient: mqttClient,
      clientFactory: (host, clientId, port) {
        final newMock = MockMqttServerClient();
        when(() => newMock.connectionStatus).thenReturn(connectionStatus);
        when(() => newMock.connect(any<String?>(), any<String?>()))
            .thenAnswer((_) async => connectionStatus);
        when(newMock.disconnect).thenAnswer((_) {});
        return newMock;
      },
    );
  });

  group('ServerMqttRepository', () {
    test('initializeMqttClient skips if settings missing', () async {
      when(() => localStorageService.getBrokerUrl()).thenReturn(null);
      when(() => localStorageService.getBrokerPort()).thenReturn(null);

      final repoWithoutClient = ServerMqttRepository();
      await repoWithoutClient.initializeMqttClient();
      expect(repoWithoutClient.mqttClient, isNull);
    });

    test('initializeMqttClient uses injected client and connects', () async {
      when(() => localStorageService.getBrokerUrl()).thenReturn('localhost');
      when(() => localStorageService.getBrokerPort()).thenReturn('1883');
      when(() => localStorageService.getBrokerUsername()).thenReturn('user');
      when(() => localStorageService.getBrokerPassword()).thenReturn('pass');
      when(() => connectionStatus.state)
          .thenReturn(MqttConnectionState.connected);

      await repository.initializeMqttClient();

      verify(() => mqttClient.connect('user', 'pass')).called(1);
      expect(repository.mqttClient, equals(mqttClient));
    });

    test('connectMqtt handles failure', () async {
      when(() => localStorageService.getBrokerUsername()).thenReturn('user');
      when(() => localStorageService.getBrokerPassword()).thenReturn('pass');
      when(() => connectionStatus.state)
          .thenReturn(MqttConnectionState.faulted);

      final expectation = expectLater(
        repository.connectionStatusStream,
        emitsThrough(BrokerConnectionStatus.disconnected),
      );

      await repository.connectMqtt();

      await expectation;
      verify(() => mqttClient.disconnect()).called(1);
    });

    test('connectMqtt handles exception', () async {
      when(() => localStorageService.getBrokerUsername()).thenReturn('user');
      when(() => localStorageService.getBrokerPassword()).thenReturn('pass');
      when(() => mqttClient.connect(any<String?>(), any<String?>()))
          .thenThrow(Exception('Failed'));
      when(
        () => crashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: any<String?>(named: 'reason'),
        ),
      ).thenAnswer((_) async {});

      final expectation = expectLater(
        repository.connectionStatusStream,
        emitsThrough(BrokerConnectionStatus.disconnected),
      );

      await repository.connectMqtt();

      await expectation;
      verify(
        () => crashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'MQTT Connection failed',
        ),
      ).called(1);
    });

    test('disconnectMqtt calls client disconnect', () {
      repository.disconnectMqtt();
      verify(() => mqttClient.disconnect()).called(1);
    });

    test('reconnectWithNewSettings re-initializes client', () async {
      when(() => localStorageService.getBrokerUrl()).thenReturn('new-host');
      when(() => localStorageService.getBrokerPort()).thenReturn('8883');
      when(() => localStorageService.getBrokerUsername()).thenReturn('u');
      when(() => localStorageService.getBrokerPassword()).thenReturn('p');
      when(() => connectionStatus.state)
          .thenReturn(MqttConnectionState.connected);

      await repository.reconnectWithNewSettings();

      expect(repository.mqttClient, isNotNull);
      expect(repository.mqttClient, isNot(equals(mqttClient)));
    });

    test('dispose cancels subscription and closes controllers', () {
      repository.dispose();
      verify(() => mqttClient.disconnect()).called(1);
    });
  });
}
