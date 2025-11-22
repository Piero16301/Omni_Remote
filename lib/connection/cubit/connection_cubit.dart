import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_remote/app/app.dart';
import 'package:user_repository/user_repository.dart';

part 'connection_state.dart';

class ConnectionCubit extends Cubit<ConnectionState> {
  ConnectionCubit(this.userRepository) : super(const ConnectionState());

  final UserRepository userRepository;

  void loadSettings() {
    emit(
      state.copyWith(
        brokerUrl: userRepository.getBrokerUrl(),
        brokerPort: userRepository.getBrokerPort(),
        brokerUsername: userRepository.getBrokerUsername(),
        brokerPassword: userRepository.getBrokerPassword(),
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

  Future<void> saveAndConnect({required BuildContext context}) async {
    if (!(state.formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Guardar la configuración en el almacenamiento persistente
    await userRepository.saveBrokerUrl(
      brokerUrl: state.brokerUrl,
    );
    await userRepository.saveBrokerPort(
      brokerPort: state.brokerPort,
    );
    await userRepository.saveBrokerUsername(
      brokerUsername: state.brokerUsername,
    );
    await userRepository.saveBrokerPassword(
      brokerPassword: state.brokerPassword,
    );

    // Conectar al broker MQTT con los nuevos ajustes
    // ignore: use_build_context_synchronously
    await context.read<AppCubit>().reconnectWithNewSettings();
  }
}
