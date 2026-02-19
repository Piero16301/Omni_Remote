import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/app/app.dart';

class MockLocalStorageService extends LocalStorageService {
  @override
  String? getBrokerUrl() => null;

  @override
  String? getBrokerPort() => null;

  @override
  String? getBrokerUsername() => null;

  @override
  String? getBrokerPassword() => null;
}

void main() {
  group('MqttService', () {
    late MqttService service;

    setUpAll(() {
      getIt.registerSingleton<LocalStorageService>(MockLocalStorageService());
    });

    tearDownAll(getIt.reset);

    setUp(() {
      service = MqttService();
    });

    tearDown(() {
      service.dispose();
    });

    test('initial state and getters', () {
      expect(service.mqttClient, isNull);
      expect(service.messageStream, isNotNull);
      expect(service.connectionStatusStream, isNotNull);
    });

    test('initializeMqttClient returns early if url is null', () async {
      await service.initializeMqttClient();
      expect(service.mqttClient, isNull);
    });

    test('disconnectMqtt works safely on null client', () {
      expect(() => service.disconnectMqtt(), returnsNormally);
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
