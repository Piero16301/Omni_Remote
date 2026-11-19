import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/app/helpers/mqtt_client_factory.dart';
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

abstract class MqttRepository {
  MqttClient? get mqttClient;
  Stream<List<MqttReceivedMessage<MqttMessage>>> get messageStream;
  Stream<BrokerConnectionStatus> get connectionStatusStream;

  Future<void> initializeMqttClient();
  Future<void> connectMqtt();
  void disconnectMqtt();
  Future<void> reconnectWithNewSettings();
  void dispose();
}

class MockMqttRepository implements MqttRepository {
  final _messageController =
      StreamController<List<MqttReceivedMessage<MqttMessage>>>.broadcast();
  final _connectionStatusController =
      StreamController<BrokerConnectionStatus>.broadcast();

  @override
  MqttClient? get mqttClient => null;

  @override
  Stream<List<MqttReceivedMessage<MqttMessage>>> get messageStream =>
      _messageController.stream;

  @override
  Stream<BrokerConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  @override
  Future<void> initializeMqttClient() async {}

  @override
  Future<void> connectMqtt() async {
    _connectionStatusController.add(BrokerConnectionStatus.connecting);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _connectionStatusController.add(BrokerConnectionStatus.connected);
  }

  @override
  void disconnectMqtt() {
    _connectionStatusController
      ..add(BrokerConnectionStatus.disconnecting)
      ..add(BrokerConnectionStatus.disconnected);
  }

  @override
  Future<void> reconnectWithNewSettings() async {
    disconnectMqtt();
    await connectMqtt();
  }

  @override
  void dispose() {
    unawaited(_messageController.close());
    unawaited(_connectionStatusController.close());
  }
}

class ServerMqttRepository implements MqttRepository {
  new({
    LocalStorageService? localStorage,
    CrashService? crashService,
    this._mqttClient,
    MqttClient Function(String host, String clientId, int port)? clientFactory,
  }) : _localStorage = localStorage ?? getIt<LocalStorageService>(),
       _crashService = crashService ?? getIt<CrashService>(),
       _clientFactory = clientFactory ?? createMqttClient;

  final LocalStorageService _localStorage;
  final CrashService _crashService;
  final MqttClient Function(String host, String clientId, int port)
  _clientFactory;

  MqttClient? _mqttClient;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _mqttSubscription;

  final _messageController =
      StreamController<List<MqttReceivedMessage<MqttMessage>>>.broadcast();
  final _connectionStatusController =
      StreamController<BrokerConnectionStatus>.broadcast();

  void _logAnalytics(String name, {Map<String, Object>? parameters}) {
    if (getIt.isRegistered<AnalyticsService>()) {
      getIt<AnalyticsService>().logEvent(name: name, parameters: parameters);
    }
  }

  @override
  MqttClient? get mqttClient => _mqttClient;

  @override
  Stream<List<MqttReceivedMessage<MqttMessage>>> get messageStream =>
      _messageController.stream;

  @override
  Stream<BrokerConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  @override
  Future<void> initializeMqttClient() async {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('mqtt_initialization');

    try {
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

      if (_mqttClient == null) {
        const uuid = Uuid();
        final port = int.parse(brokerPort);

        _mqttClient = _clientFactory(brokerUrl, uuid.v4(), port);
        configureMqttClientTls(_mqttClient!, port);
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
    } on Exception catch (e, stackTrace) {
      _crashService.recordError(
        e,
        stackTrace,
        reason: 'MQTT Initialization failed',
      );
      rethrow;
    } finally {
      performance.stopTrace(trace);
    }
  }

  @override
  Future<void> connectMqtt() async {
    if (_mqttClient == null) return;

    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('mqtt_connection');

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
        _logAnalytics('mqtt_connected');
        _connectionStatusController.add(BrokerConnectionStatus.connected);
      } else {
        _logAnalytics(
          'mqtt_connection_failed',
          parameters: {
            'state': _mqttClient!.connectionStatus?.state.name ?? 'unknown',
          },
        );
        _connectionStatusController.add(BrokerConnectionStatus.disconnected);
        _mqttClient?.disconnect();
      }
    } on Exception catch (e, stackTrace) {
      _crashService.recordError(
        e,
        stackTrace,
        reason: 'MQTT Connection failed',
      );
      _logAnalytics(
        'mqtt_connection_failed',
        parameters: {'state': 'exception'},
      );
      _connectionStatusController.add(BrokerConnectionStatus.disconnected);
      _mqttClient?.disconnect();
    } finally {
      performance.stopTrace(trace);
    }
  }

  @override
  void disconnectMqtt() {
    if (_mqttClient == null) return;
    unawaited(_mqttSubscription?.cancel());
    _connectionStatusController.add(BrokerConnectionStatus.disconnecting);
    _mqttClient?.disconnect();
  }

  @override
  Future<void> reconnectWithNewSettings() async {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('mqtt_reconnect_with_new_settings');
    try {
      // Desconectar el cliente actual si existe
      if (_mqttClient != null) {
        unawaited(_mqttSubscription?.cancel());
        _mqttClient?.disconnect();
        _mqttClient = null;
      }

      // Reinicializar con los nuevos datos
      await initializeMqttClient();
    } finally {
      performance.stopTrace(trace);
    }
  }

  void _setupMqttListener() {
    unawaited(_mqttSubscription?.cancel());
    _mqttSubscription = _mqttClient?.updates?.listen(_messageController.add);
  }

  void _onMqttConnected() {
    _setupMqttListener();
    _connectionStatusController.add(BrokerConnectionStatus.connected);
  }

  void _onMqttDisconnected() {
    unawaited(_mqttSubscription?.cancel());
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(BrokerConnectionStatus.disconnected);
    }
  }

  void _onMqttAutoReconnect() {
    _connectionStatusController.add(BrokerConnectionStatus.connecting);
  }

  void _onMqttAutoReconnected() {
    _setupMqttListener();
    _logAnalytics('mqtt_auto_reconnected');
    _connectionStatusController.add(BrokerConnectionStatus.connected);
  }

  @override
  void dispose() {
    unawaited(_mqttSubscription?.cancel());
    unawaited(_messageController.close());
    unawaited(_connectionStatusController.close());
    _mqttClient?.disconnect();
  }
}
