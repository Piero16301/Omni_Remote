import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:omni_remote/app/app.dart';

class MockMqttRepository extends Mock implements MqttRepository {}

class MockMqttServerClient extends Mock implements MqttServerClient {}

void main() {
  late MqttRepository repository;
  late MqttService service;

  setUp(() {
    repository = MockMqttRepository();
    service = MqttService(mqttRepository: repository);
  });

  group('MqttService', () {
    test('mqttClient returns repository.mqttClient', () {
      final client = MockMqttServerClient();
      when(() => repository.mqttClient).thenReturn(client);
      final result = service.mqttClient;
      expect(result, equals(client));
      verify(() => repository.mqttClient).called(1);
    });

    test('messageStream returns repository.messageStream', () {
      const stream = Stream<List<MqttReceivedMessage<MqttMessage>>>.empty();
      when(() => repository.messageStream).thenAnswer((_) => stream);
      final result = service.messageStream;
      expect(result, equals(stream));
      verify(() => repository.messageStream).called(1);
    });

    test('connectionStatusStream returns repository.connectionStatusStream',
        () {
      const stream = Stream<BrokerConnectionStatus>.empty();
      when(() => repository.connectionStatusStream).thenAnswer((_) => stream);
      final result = service.connectionStatusStream;
      expect(result, equals(stream));
      verify(() => repository.connectionStatusStream).called(1);
    });

    test('initializeMqttClient calls repository.initializeMqttClient',
        () async {
      when(() => repository.initializeMqttClient()).thenAnswer((_) async {});
      await service.initializeMqttClient();
      verify(() => repository.initializeMqttClient()).called(1);
    });

    test('connectMqtt calls repository.connectMqtt', () async {
      when(() => repository.connectMqtt()).thenAnswer((_) async {});
      await service.connectMqtt();
      verify(() => repository.connectMqtt()).called(1);
    });

    test('disconnectMqtt calls repository.disconnectMqtt', () {
      service.disconnectMqtt();
      verify(() => repository.disconnectMqtt()).called(1);
    });

    test('reconnectWithNewSettings calls repository.reconnectWithNewSettings',
        () async {
      when(() => repository.reconnectWithNewSettings())
          .thenAnswer((_) async {});
      await service.reconnectWithNewSettings();
      verify(() => repository.reconnectWithNewSettings()).called(1);
    });

    test('dispose calls repository.dispose', () {
      service.dispose();
      verify(() => repository.dispose()).called(1);
    });
  });
}
