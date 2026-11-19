import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:omni_remote/app/helpers/mqtt_client_factory_io.dart';

class MockMqttClient extends Mock implements MqttClient;

class MockX509Certificate extends Mock implements X509Certificate;

void main() {
  group('mqtt_client_factory_io', () {
    test(
      'createMqttClient returns MqttServerClient with host, id, and port',
      () {
      final client = createMqttClient('broker.example.com', 'client-1', 1883);

      expect(client, isA<MqttServerClient>());
      expect(client.server, equals('broker.example.com'));
      expect(client.clientIdentifier, equals('client-1'));
      expect(client.port, equals(1883));
    });

    test(
      'configureMqttClientTls configures TLS and onBadCertificate for 8883',
      () {
      final client =
          createMqttClient('broker.example.com', 'client-1', 8883)
              as MqttServerClient;

      configureMqttClientTls(client, 8883);

      expect(client.secure, isTrue);
      expect(client.securityContext, equals(SecurityContext.defaultContext));
      expect(client.onBadCertificate, isNotNull);
      expect(client.onBadCertificate!(MockX509Certificate()), isTrue);
    });

    test('configureMqttClientTls does not enable TLS for non-8883 port', () {
      final client =
          createMqttClient('broker.example.com', 'client-1', 1883)
              as MqttServerClient;

      configureMqttClientTls(client, 1883);

      expect(client.secure, isFalse);
      expect(client.onBadCertificate, isNull);
    });

    test('configureMqttClientTls ignores non-MqttServerClient instances', () {
      final client = MockMqttClient();

      expect(() => configureMqttClientTls(client, 8883), returnsNormally);
      verifyZeroInteractions(client);
    });
  });
}
