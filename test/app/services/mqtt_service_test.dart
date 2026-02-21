import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  group('MqttService', () {
    late MqttService service;
    late MockLocalStorageService mockLocalStorageService;

    setUp(() async {
      mockLocalStorageService = MockLocalStorageService();
      if (!getIt.isRegistered<LocalStorageService>()) {
        getIt.registerSingleton<LocalStorageService>(mockLocalStorageService);
      } else {
        await getIt.unregister<LocalStorageService>();
        getIt.registerSingleton<LocalStorageService>(mockLocalStorageService);
      }
      service = MqttService();
    });

    tearDown(() {
      service.dispose();
      unawaited(getIt.reset());
    });

    test('initial state and getters', () {
      expect(service.mqttClient, isNull);
      expect(service.messageStream, isNotNull);
      expect(service.connectionStatusStream, isNotNull);
    });

    test('initializeMqttClient returns early if url is null', () async {
      when(() => mockLocalStorageService.getBrokerUrl()).thenReturn(null);
      when(() => mockLocalStorageService.getBrokerPort()).thenReturn(null);

      await service.initializeMqttClient();
      expect(service.mqttClient, isNull);
    });

    test('disconnectMqtt works safely on null client', () {
      expect(() => service.disconnectMqtt(), returnsNormally);
    });

    test(
        'initializeMqttClient creates client and connects, throwing exception '
        'on invalid broker', () async {
      when(() => mockLocalStorageService.getBrokerUrl())
          .thenReturn('127.0.0.1');
      when(() => mockLocalStorageService.getBrokerPort()).thenReturn('1883');
      when(() => mockLocalStorageService.getBrokerUsername())
          .thenReturn('user');
      when(() => mockLocalStorageService.getBrokerPassword())
          .thenReturn('pass');

      unawaited(
        expectLater(
          service.connectionStatusStream,
          emitsInOrder([
            BrokerConnectionStatus.connecting,
            BrokerConnectionStatus.disconnected,
          ]),
        ),
      );

      await service.initializeMqttClient();
      expect(service.mqttClient, isNotNull);
      expect(service.mqttClient?.secure, isFalse);
    });

    test('initializeMqttClient configures TLS securely', () async {
      when(() => mockLocalStorageService.getBrokerUrl())
          .thenReturn('127.0.0.1');
      when(() => mockLocalStorageService.getBrokerPort()).thenReturn('8883');
      when(() => mockLocalStorageService.getBrokerUsername())
          .thenReturn('user');
      when(() => mockLocalStorageService.getBrokerPassword())
          .thenReturn('pass');

      unawaited(
        expectLater(
          service.connectionStatusStream,
          emitsInOrder([
            BrokerConnectionStatus.connecting,
            BrokerConnectionStatus.disconnected,
          ]),
        ),
      );

      await service.initializeMqttClient();
      expect(service.mqttClient, isNotNull);
      expect(service.mqttClient?.secure, isTrue);
    });

    test(
        'reconnectWithNewSettings disconnects gracefully and reinitializes '
        'empty', () async {
      when(() => mockLocalStorageService.getBrokerUrl())
          .thenReturn('127.0.0.1');
      when(() => mockLocalStorageService.getBrokerPort()).thenReturn('1883');
      when(() => mockLocalStorageService.getBrokerUsername())
          .thenReturn('user');
      when(() => mockLocalStorageService.getBrokerPassword())
          .thenReturn('pass');

      await service.initializeMqttClient();
      expect(service.mqttClient, isNotNull);

      when(() => mockLocalStorageService.getBrokerUrl()).thenReturn(null);
      when(() => mockLocalStorageService.getBrokerPort()).thenReturn(null);

      await service.reconnectWithNewSettings();
      expect(service.mqttClient, isNull);
    });

    test('connectMqtt ignores when client is null', () async {
      await service.connectMqtt();
      expect(service.mqttClient, isNull);
    });
  });

  group('BrokerConnectionStatus', () {
    test('returns correct booleans for enum properties', () {
      expect(BrokerConnectionStatus.disconnected.isDisconnected, isTrue);
      expect(BrokerConnectionStatus.connecting.isConnecting, isTrue);
      expect(BrokerConnectionStatus.connected.isConnected, isTrue);
      expect(BrokerConnectionStatus.disconnecting.isDisconnecting, isTrue);

      expect(BrokerConnectionStatus.disconnected.isConnected, isFalse);
    });
  });
}
