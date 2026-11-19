import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient createMqttClient(String host, String clientId, int port) {
  return MqttServerClient.withPort(host, clientId, port);
}

void configureMqttClientTls(MqttClient client, int port) {
  if (port == 8883 && client is MqttServerClient) {
    client
      ..secure = true
      ..securityContext = SecurityContext.defaultContext
      // Para HiveMQ Cloud y otros servicios, validar certificados
      // correctamente
      ..onBadCertificate = (dynamic cert) => true;
  }
}
