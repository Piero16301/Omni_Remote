import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_remote/app/app.dart';

part 'connection_state.dart';

class ConnectionCubit extends Cubit<ConnectionState> {
  ConnectionCubit() : super(const ConnectionState());

  final LocalStorageService localStorage = getIt<LocalStorageService>();

  void loadSettings() {
    emit(
      state.copyWith(
        brokerUrl: localStorage.getBrokerUrl(),
        brokerPort: localStorage.getBrokerPort(),
        brokerUsername: localStorage.getBrokerUsername(),
        brokerPassword: localStorage.getBrokerPassword(),
      ),
    );
  }

  void changeBrokerUrl(String url) {
    emit(state.copyWith(brokerUrl: url));
  }

  void changeBrokerPort(String port) {
    emit(state.copyWith(brokerPort: port));
  }

  void changeBrokerUsername(String username) {
    emit(state.copyWith(brokerUsername: username));
  }

  void changeBrokerPassword(String password) {
    emit(state.copyWith(brokerPassword: password));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(hidePassword: !state.hidePassword));
  }

  Future<void> saveAndConnect({required BuildContext context}) async {
    if (!(state.formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Guardar la configuración en el almacenamiento persistente
    localStorage
      ..saveBrokerUrl(brokerUrl: state.brokerUrl)
      ..saveBrokerPort(brokerPort: state.brokerPort)
      ..saveBrokerUsername(brokerUsername: state.brokerUsername)
      ..saveBrokerPassword(brokerPassword: state.brokerPassword);

    // Conectar al broker MQTT con los nuevos ajustes
    await context.read<AppCubit>().reconnectWithNewSettings();
  }

  void disconnectBroker({required BuildContext context}) {
    context.read<AppCubit>().disconnectMqtt();
  }
}
