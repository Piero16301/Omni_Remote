import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:omni_remote/app/app.dart';
import 'package:user_repository/user_repository.dart';
import 'package:uuid/uuid.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(this.userRepository) : super(const AppState());

  final UserRepository userRepository;
  MqttServerClient? _mqttClient;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _mqttSubscription;
  final _messageController =
      StreamController<List<MqttReceivedMessage<MqttMessage>>>.broadcast();

  MqttServerClient? get mqttClient => _mqttClient;
  Stream<List<MqttReceivedMessage<MqttMessage>>> get messageStream =>
      _messageController.stream;

  Future<void> initialLoad() async {
    // Setting the language to the device language if it's not set
    final language = userRepository.getLanguage();
    if (language == null) {
      final deviceLanguage = Platform.localeName;
      await userRepository.saveLanguage(language: deviceLanguage);
    }
    emit(state.copyWith(language: userRepository.getLanguage()));

    // Setting the theme to the device theme if it's not set
    final theme = userRepository.getTheme();
    if (theme == null) {
      final deviceBrightness = PlatformDispatcher.instance.platformBrightness;
      await userRepository.saveTheme(
        theme: deviceBrightness == Brightness.dark ? 'DARK' : 'LIGHT',
      );
    }
    emit(state.copyWith(theme: userRepository.getTheme()));

    // Setting the base color to INDIGO if it's not set
    final baseColor = userRepository.getBaseColor();
    if (baseColor == null) {
      await userRepository.saveBaseColor(
        baseColor: AppVariables.defaultBaseColor,
      );
    }
    emit(state.copyWith(baseColor: userRepository.getBaseColor()));

    // Initialize MQTT Client
    await _initializeMqttClient();
  }

  Future<void> changeLanguage({required String language}) async {
    await userRepository.saveLanguage(language: language);
    emit(state.copyWith(language: language));
  }

  Future<void> changeTheme({required String theme}) async {
    await userRepository.saveTheme(theme: theme);
    emit(state.copyWith(theme: theme));
  }

  Future<void> changeBaseColor({required String baseColor}) async {
    await userRepository.saveBaseColor(baseColor: baseColor);
    emit(state.copyWith(baseColor: baseColor));
  }

  Future<void> _initializeMqttClient() async {
    final brokerUrl = userRepository.getBrokerUrl();
    final brokerPort = userRepository.getBrokerPort();
    final username = userRepository.getBrokerUsername();
    final password = userRepository.getBrokerPassword();

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
        userRepository.getBrokerUsername(),
        userRepository.getBrokerPassword(),
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
