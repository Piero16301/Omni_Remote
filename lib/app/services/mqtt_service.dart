import 'package:mqtt_client/mqtt_client.dart';
import 'package:omni_remote/app/app.dart';

class MqttService {
  new({required this._mqttRepository});

  final MqttRepository _mqttRepository;

  MqttClient? get mqttClient => _mqttRepository.mqttClient;

  Stream<List<MqttReceivedMessage<MqttMessage>>> get messageStream =>
      _mqttRepository.messageStream;

  Stream<BrokerConnectionStatus> get connectionStatusStream =>
      _mqttRepository.connectionStatusStream;

  Future<void> initializeMqttClient() => _mqttRepository.initializeMqttClient();

  Future<void> connectMqtt() => _mqttRepository.connectMqtt();

  void disconnectMqtt() => _mqttRepository.disconnectMqtt();

  Future<void> reconnectWithNewSettings() =>
      _mqttRepository.reconnectWithNewSettings();

  void dispose() => _mqttRepository.dispose();
}
