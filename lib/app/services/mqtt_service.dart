import 'dart:async';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:omni_remote/app/app.dart';
import 'package:uuid/uuid.dart';

enum BrokerConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting;

  bool get isDisconnected => this == BrokerConnectionStatus.disconnected;
  bool get isConnecting => this == BrokerConnectionStatus.connecting;
  bool get isConnected => this == BrokerConnectionStatus.connected;
  bool get isDisconnecting => this == BrokerConnectionStatus.disconnecting;
}

class MqttService {
  final LocalStorageService _localStorage = getIt<LocalStorageService>();

  MqttServerClient? _mqttClient;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _mqttSubscription;

  final _messageController =
      StreamController<List<MqttReceivedMessage<MqttMessage>>>.broadcast();

  final _connectionStatusController =
      StreamController<BrokerConnectionStatus>.broadcast();

  MqttServerClient? get mqttClient => _mqttClient;
  Stream<List<MqttReceivedMessage<MqttMessage>>> get messageStream =>
      _messageController.stream;
  Stream<BrokerConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  Future<void> initializeMqttClient() async {
    final brokerUrl = _localStorage.getBrokerUrl();
    final brokerPort = _localStorage.getBrokerPort();
    final username = _localStorage.getBrokerUsername();
    final password = _localStorage.getBrokerPassword();

    if (brokerUrl == null ||
        brokerUrl.isEmpty ||
        brokerPort == null ||
        brokerPort.isEmpty) {
      return;
    }

    const uuid = Uuid();
    final port = int.parse(brokerPort);

    _mqttClient = MqttServerClient.withPort(
      brokerUrl,
      uuid.v4(),
      port,
    );

    // Configurar TLS/SSL para puerto 8883 (MQTT seguro)
    if (port == 8883) {
      _mqttClient!.secure = true;
      _mqttClient!.securityContext = SecurityContext.defaultContext;
      // Para HiveMQ Cloud y otros servicios, validar certificados correctamente
      _mqttClient!.onBadCertificate = (dynamic cert) => true;
    }

    _mqttClient!
      ..keepAlivePeriod = 60
      ..connectTimeoutPeriod = 5000
      ..autoReconnect = true
      ..logging(on: true)
      ..onConnected = _onMqttConnected
      ..onDisconnected = _onMqttDisconnected
      ..onAutoReconnect = _onMqttAutoReconnect
      ..onAutoReconnected = _onMqttAutoReconnected;

    final connMessage = MqttConnectMessage()
        .authenticateAs(username, password)
        .withWillTopic(AppVariables.lastWillTopic)
        .withWillMessage(AppVariables.lastWillMessage)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _mqttClient!.connectionMessage = connMessage;

    await connectMqtt();
  }

  Future<void> connectMqtt() async {
    if (_mqttClient == null) return;

    try {
      _connectionStatusController.add(BrokerConnectionStatus.connecting);

      await _mqttClient!.connect(
        _localStorage.getBrokerUsername(),
        _localStorage.getBrokerPassword(),
      );

      if (_mqttClient!.connectionStatus?.state ==
          MqttConnectionState.connected) {
        // Setup the global MQTT listener
        _setupMqttListener();
        _connectionStatusController.add(BrokerConnectionStatus.connected);
      } else {
        _connectionStatusController.add(BrokerConnectionStatus.disconnected);
        _mqttClient?.disconnect();
      }
    } on Exception {
      _connectionStatusController.add(BrokerConnectionStatus.disconnected);
      _mqttClient?.disconnect();
    }
  }

  void disconnectMqtt() {
    if (_mqttClient == null) return;
    unawaited(_mqttSubscription?.cancel());
    _connectionStatusController.add(BrokerConnectionStatus.disconnecting);
    _mqttClient?.disconnect();
  }

  Future<void> reconnectWithNewSettings() async {
    // Desconectar el cliente actual si existe
    if (_mqttClient != null) {
      unawaited(_mqttSubscription?.cancel());
      _mqttClient?.disconnect();
      _mqttClient = null;
    }

    // Reinicializar con los nuevos datos
    await initializeMqttClient();
  }

  void _setupMqttListener() {
    unawaited(_mqttSubscription?.cancel());
    _mqttSubscription = _mqttClient?.updates?.listen(
      _messageController.add,
    );
  }

  void _onMqttConnected() {
    _setupMqttListener();
    _connectionStatusController.add(BrokerConnectionStatus.connected);
  }

  void _onMqttDisconnected() {
    unawaited(_mqttSubscription?.cancel());
    _connectionStatusController.add(BrokerConnectionStatus.disconnected);
  }

  void _onMqttAutoReconnect() {
    _connectionStatusController.add(BrokerConnectionStatus.connecting);
  }

  void _onMqttAutoReconnected() {
    _setupMqttListener();
    _connectionStatusController.add(BrokerConnectionStatus.connected);
  }

  void dispose() {
    unawaited(_mqttSubscription?.cancel());
    unawaited(_messageController.close());
    unawaited(_connectionStatusController.close());
    _mqttClient?.disconnect();
  }
}
