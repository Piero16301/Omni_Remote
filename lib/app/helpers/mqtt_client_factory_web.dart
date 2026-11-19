import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

MqttClient createMqttClient(String host, String clientId, int port) {
  final wsHost = host.startsWith('ws://') || host.startsWith('wss://')
      ? host
      : (port == 8883 || port == 8884 || port == 443)
      ? 'wss://$host/mqtt'
      : 'ws://$host/mqtt';
  return MqttBrowserClient.withPort(wsHost, clientId, port);
}

void configureMqttClientTls(MqttClient client, int port) {}
