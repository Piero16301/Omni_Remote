import 'dart:async';
import 'dart:io';

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

class MockX509Certificate extends Mock implements X509Certificate {}

class FakeMqttServerClient extends Mock implements MqttServerClient {
  @override
  void Function()? onConnected;
  @override
  void Function()? onDisconnected;
  @override
  void Function()? onAutoReconnect;
  @override
  void Function()? onAutoReconnected;
  @override
  bool Function(X509Certificate certificate)? onBadCertificate;
  @override
  bool secure = false;
  @override
  SecurityContext securityContext = SecurityContext.defaultContext;
  @override
  Stream<List<MqttReceivedMessage<MqttMessage>>>? updates;
  @override
  int keepAlivePeriod = 0;
  @override
  int connectTimeoutPeriod = 0;
  @override
  bool autoReconnect = false;
  @override
  MqttConnectMessage? connectionMessage;
  @override
  void logging({required bool on, bool logPayloads = true}) {}
}

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
    when(
      () => mqttClient.connect(any<String?>(), any<String?>()),
    ).thenAnswer((_) async => connectionStatus);
    when(() => mqttClient.disconnect()).thenAnswer((_) {});

    repository = ServerMqttRepository(
      mqttClient: mqttClient,
      clientFactory: (host, clientId, port) {
        final newMock = MockMqttServerClient();
        when(() => newMock.connectionStatus).thenReturn(connectionStatus);
        when(
          () => newMock.connect(any<String?>(), any<String?>()),
        ).thenAnswer((_) async => connectionStatus);
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
      when(
        () => connectionStatus.state,
      ).thenReturn(MqttConnectionState.connected);

      await repository.initializeMqttClient();

      verify(() => mqttClient.connect('user', 'pass')).called(1);
      expect(repository.mqttClient, equals(mqttClient));
    });

    test('connectMqtt handles failure', () async {
      when(() => localStorageService.getBrokerUsername()).thenReturn('user');
      when(() => localStorageService.getBrokerPassword()).thenReturn('pass');
      when(
        () => connectionStatus.state,
      ).thenReturn(MqttConnectionState.faulted);

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
      when(
        () => mqttClient.connect(any<String?>(), any<String?>()),
      ).thenThrow(Exception('Failed'));
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

    test('connectMqtt returns early if _mqttClient is null', () async {
      final repo = ServerMqttRepository();
      await repo.connectMqtt();
      expect(repo.mqttClient, isNull);
    });

    test('disconnectMqtt returns early if _mqttClient is null', () {
      final repo = ServerMqttRepository();
      expect(repo.disconnectMqtt, returnsNormally);
    });

    test(
      'initializeMqttClient configures TLS and onBadCertificate for port 8883',
      () async {
        final fakeClient = FakeMqttServerClient();
        when(() => fakeClient.connectionStatus).thenReturn(connectionStatus);
        when(
          () => fakeClient.connect(any<String?>(), any<String?>()),
        ).thenAnswer((_) async => connectionStatus);
        when(fakeClient.disconnect).thenAnswer((_) {});
        when(
          () => connectionStatus.state,
        ).thenReturn(MqttConnectionState.connected);

        when(
          () => localStorageService.getBrokerUrl(),
        ).thenReturn('secure-broker.com');
        when(() => localStorageService.getBrokerPort()).thenReturn('8883');
        when(() => localStorageService.getBrokerUsername()).thenReturn('user');
        when(() => localStorageService.getBrokerPassword()).thenReturn('pass');

        final repo = ServerMqttRepository(
          clientFactory: (host, clientId, port) => fakeClient,
        );

        await repo.initializeMqttClient();

        expect(fakeClient.secure, isTrue);
        expect(fakeClient.securityContext, isNotNull);
        expect(
          fakeClient.onBadCertificate?.call(MockX509Certificate()),
          isTrue,
        );
      },
    );

    test('triggers onConnected, onDisconnected, onAutoReconnect, '
        'onAutoReconnected, and forwards updates', () async {
      final fakeClient = FakeMqttServerClient();
      final updatesController =
          StreamController<List<MqttReceivedMessage<MqttMessage>>>.broadcast();
      fakeClient.updates = updatesController.stream;

      when(() => fakeClient.connectionStatus).thenReturn(connectionStatus);
      when(
        () => fakeClient.connect(any<String?>(), any<String?>()),
      ).thenAnswer((_) async => connectionStatus);
      when(fakeClient.disconnect).thenAnswer((_) {});
      when(
        () => connectionStatus.state,
      ).thenReturn(MqttConnectionState.connected);

      when(() => localStorageService.getBrokerUrl()).thenReturn('localhost');
      when(() => localStorageService.getBrokerPort()).thenReturn('1883');
      when(() => localStorageService.getBrokerUsername()).thenReturn('u');
      when(() => localStorageService.getBrokerPassword()).thenReturn('p');

      final repo = ServerMqttRepository(
        clientFactory: (host, clientId, port) => fakeClient,
      );

      await repo.initializeMqttClient();

      // Test onAutoReconnect callback
      final reconnectingFuture = expectLater(
        repo.connectionStatusStream,
        emits(BrokerConnectionStatus.connecting),
      );
      fakeClient.onAutoReconnect?.call();
      await reconnectingFuture;

      // Test onAutoReconnected callback
      final reconnectedFuture = expectLater(
        repo.connectionStatusStream,
        emits(BrokerConnectionStatus.connected),
      );
      fakeClient.onAutoReconnected?.call();
      await reconnectedFuture;

      // Test onDisconnected callback
      final disconnectedFuture = expectLater(
        repo.connectionStatusStream,
        emits(BrokerConnectionStatus.disconnected),
      );
      fakeClient.onDisconnected?.call();
      await disconnectedFuture;

      // Test onConnected callback
      final connectedFuture = expectLater(
        repo.connectionStatusStream,
        emits(BrokerConnectionStatus.connected),
      );
      fakeClient.onConnected?.call();
      await connectedFuture;

      // Test messageStream receives updates
      final dummyMsg = <MqttReceivedMessage<MqttMessage>>[];
      final msgFuture = expectLater(repo.messageStream, emits(dummyMsg));
      updatesController.add(dummyMsg);
      await msgFuture;

      await updatesController.close();
      repo.dispose();
    });

    test('reconnectWithNewSettings re-initializes client', () async {
      when(() => localStorageService.getBrokerUrl()).thenReturn('new-host');
      when(() => localStorageService.getBrokerPort()).thenReturn('8883');
      when(() => localStorageService.getBrokerUsername()).thenReturn('u');
      when(() => localStorageService.getBrokerPassword()).thenReturn('p');
      when(
        () => connectionStatus.state,
      ).thenReturn(MqttConnectionState.connected);

      await repository.reconnectWithNewSettings();

      expect(repository.mqttClient, isNotNull);
      expect(repository.mqttClient, isNot(equals(mqttClient)));
    });

    test('dispose cancels subscription and closes controllers', () {
      repository.dispose();
      verify(() => mqttClient.disconnect()).called(1);
    });
  });

  group('BrokerConnectionStatus', () {
    test('extension getters return correct boolean values', () {
      expect(BrokerConnectionStatus.disconnected.isDisconnected, isTrue);
      expect(BrokerConnectionStatus.disconnected.isConnecting, isFalse);
      expect(BrokerConnectionStatus.disconnected.isConnected, isFalse);
      expect(BrokerConnectionStatus.disconnected.isDisconnecting, isFalse);

      expect(BrokerConnectionStatus.connecting.isDisconnected, isFalse);
      expect(BrokerConnectionStatus.connecting.isConnecting, isTrue);
      expect(BrokerConnectionStatus.connecting.isConnected, isFalse);
      expect(BrokerConnectionStatus.connecting.isDisconnecting, isFalse);

      expect(BrokerConnectionStatus.connected.isDisconnected, isFalse);
      expect(BrokerConnectionStatus.connected.isConnecting, isFalse);
      expect(BrokerConnectionStatus.connected.isConnected, isTrue);
      expect(BrokerConnectionStatus.connected.isDisconnecting, isFalse);

      expect(BrokerConnectionStatus.disconnecting.isDisconnected, isFalse);
      expect(BrokerConnectionStatus.disconnecting.isConnecting, isFalse);
      expect(BrokerConnectionStatus.disconnecting.isConnected, isFalse);
      expect(BrokerConnectionStatus.disconnecting.isDisconnecting, isTrue);
    });
  });

  group('MockMqttRepository', () {
    late MockMqttRepository mockRepo;

    setUp(() {
      mockRepo = MockMqttRepository();
    });

    tearDown(() {
      mockRepo.dispose();
    });

    test('mqttClient is null', () {
      expect(mockRepo.mqttClient, isNull);
    });

    test('initializeMqttClient completes normally', () async {
      await expectLater(mockRepo.initializeMqttClient(), completes);
    });

    test('connectMqtt emits connecting and connected', () async {
      final expectation = expectLater(
        mockRepo.connectionStatusStream,
        emitsInOrder([
          BrokerConnectionStatus.connecting,
          BrokerConnectionStatus.connected,
        ]),
      );
      await mockRepo.connectMqtt();
      await expectation;
    });

    test('disconnectMqtt emits disconnecting and disconnected', () async {
      final expectation = expectLater(
        mockRepo.connectionStatusStream,
        emitsInOrder([
          BrokerConnectionStatus.disconnecting,
          BrokerConnectionStatus.disconnected,
        ]),
      );
      mockRepo.disconnectMqtt();
      await expectation;
    });

    test('reconnectWithNewSettings disconnects and reconnects', () async {
      final expectation = expectLater(
        mockRepo.connectionStatusStream,
        emitsInOrder([
          BrokerConnectionStatus.disconnecting,
          BrokerConnectionStatus.disconnected,
          BrokerConnectionStatus.connecting,
          BrokerConnectionStatus.connected,
        ]),
      );
      await mockRepo.reconnectWithNewSettings();
      await expectation;
    });

    test('messageStream is accessible', () {
      expect(mockRepo.messageStream, isNotNull);
    });
  });
}
