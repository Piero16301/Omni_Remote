import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:omni_remote/app/app.dart';
import 'package:uuid/uuid.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  final LocalStorageService localStorage = getIt<LocalStorageService>();

  MqttServerClient? _mqttClient;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _mqttSubscription;
  final _messageController =
      StreamController<List<MqttReceivedMessage<MqttMessage>>>.broadcast();

  MqttServerClient? get mqttClient => _mqttClient;
  Stream<List<MqttReceivedMessage<MqttMessage>>> get messageStream =>
      _messageController.stream;

  Future<void> initialLoad() async {
    // Setting the language to the device language if it's not set
    final language = localStorage.getLanguage();
    if (language == null) {
      final deviceLanguage = AppVariables.supportedLocales.first;
      localStorage.saveLanguage(language: deviceLanguage);
    }

    // Setting the theme to the device theme if it's not set
    final theme = localStorage.getTheme();
    if (theme == null) {
      localStorage.saveTheme(theme: ThemeMode.system);
    }

    // Setting the base color to GREEN if it's not set
    final baseColor = localStorage.getBaseColor();
    if (baseColor == null) {
      localStorage.saveBaseColor(baseColor: AppVariables.defaultBaseColor);
    }

    // Setting the font family to Popping if it's not set
    var fontFamily = localStorage.getFontFamily();
    final isFontSupported = fontFamily != null &&
        AppVariables.availableFonts.containsValue(fontFamily);

    if (!isFontSupported) {
      final defaultFont =
          AppVariables.availableFonts[AppVariables.defaultFontFamily] ??
              AppVariables.defaultFontFamily;
      localStorage.saveFontFamily(fontFamily: defaultFont);
      fontFamily = defaultFont;
    }

    // Emit state with all loaded configurations at once
    emit(
      state.copyWith(
        language: localStorage.getLanguage(),
        theme: localStorage.getTheme(),
        baseColor: localStorage.getBaseColor(),
        fontFamily: localStorage.getFontFamily(),
      ),
    );

    // Initialize MQTT Client
    await _initializeMqttClient();
  }

  void changeLanguage({required Locale language}) {
    localStorage.saveLanguage(language: language);
    emit(state.copyWith(language: language));
  }

  void changeTheme({required ThemeMode theme}) {
    localStorage.saveTheme(theme: theme);
    emit(state.copyWith(theme: theme));
  }

  void changeBaseColor({required Color baseColor}) {
    localStorage.saveBaseColor(baseColor: baseColor);
    emit(state.copyWith(baseColor: baseColor));
  }

  void changeFontFamily({required String fontFamily}) {
    localStorage.saveFontFamily(fontFamily: fontFamily);
    emit(state.copyWith(fontFamily: fontFamily));
  }

  Future<void> _initializeMqttClient() async {
    final brokerUrl = localStorage.getBrokerUrl();
    final brokerPort = localStorage.getBrokerPort();
    final username = localStorage.getBrokerUsername();
    final password = localStorage.getBrokerPassword();

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
      emit(
        state.copyWith(
          brokerConnectionStatus: BrokerConnectionStatus.connecting,
        ),
      );

      await _mqttClient!.connect(
        localStorage.getBrokerUsername(),
        localStorage.getBrokerPassword(),
      );

      if (_mqttClient!.connectionStatus?.state ==
          MqttConnectionState.connected) {
        // Setup the global MQTT listener
        _setupMqttListener();

        emit(
          state.copyWith(
            brokerConnectionStatus: BrokerConnectionStatus.connected,
          ),
        );
      } else {
        emit(
          state.copyWith(
            brokerConnectionStatus: BrokerConnectionStatus.disconnected,
          ),
        );
        _mqttClient?.disconnect();
      }
    } on Exception {
      emit(
        state.copyWith(
          brokerConnectionStatus: BrokerConnectionStatus.disconnected,
        ),
      );
      _mqttClient?.disconnect();
    }
  }

  void disconnectMqtt() {
    if (_mqttClient == null) return;
    unawaited(_mqttSubscription?.cancel());
    emit(
      state.copyWith(
        brokerConnectionStatus: BrokerConnectionStatus.disconnecting,
      ),
    );
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
    await _initializeMqttClient();
  }

  void _setupMqttListener() {
    unawaited(_mqttSubscription?.cancel());
    _mqttSubscription = _mqttClient?.updates?.listen(
      _messageController.add,
    );
  }

  void _onMqttConnected() {
    _setupMqttListener();
    emit(
      state.copyWith(brokerConnectionStatus: BrokerConnectionStatus.connected),
    );
  }

  void _onMqttDisconnected() {
    unawaited(_mqttSubscription?.cancel());
    emit(
      state.copyWith(
        brokerConnectionStatus: BrokerConnectionStatus.disconnected,
      ),
    );
  }

  void _onMqttAutoReconnect() {
    emit(
      state.copyWith(brokerConnectionStatus: BrokerConnectionStatus.connecting),
    );
  }

  void _onMqttAutoReconnected() {
    _setupMqttListener();
    emit(
      state.copyWith(brokerConnectionStatus: BrokerConnectionStatus.connected),
    );
  }

  @override
  Future<void> close() {
    unawaited(_mqttSubscription?.cancel());
    unawaited(_messageController.close());
    _mqttClient?.disconnect();
    return super.close();
  }
}
