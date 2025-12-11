part of 'connection_cubit.dart';

class ConnectionState extends Equatable {
  const ConnectionState({
    this.brokerUrl = '',
    this.brokerPort = '',
    this.brokerUsername = '',
    this.brokerPassword = '',
    this.hidePassword = true,
    this.formKey = const GlobalObjectKey<FormState>('connection_form'),
  });

  final String brokerUrl;
  final String brokerPort;
  final String brokerUsername;
  final String brokerPassword;
  final bool hidePassword;
  final GlobalKey<FormState> formKey;

  ConnectionState copyWith({
    String? brokerUrl,
    String? brokerPort,
    String? brokerUsername,
    String? brokerPassword,
    bool? hidePassword,
    GlobalKey<FormState>? formKey,
  }) {
    return ConnectionState(
      brokerUrl: brokerUrl ?? this.brokerUrl,
      brokerPort: brokerPort ?? this.brokerPort,
      brokerUsername: brokerUsername ?? this.brokerUsername,
      brokerPassword: brokerPassword ?? this.brokerPassword,
      hidePassword: hidePassword ?? this.hidePassword,
      formKey: formKey ?? this.formKey,
    );
  }

  @override
  List<Object> get props => [
        brokerUrl,
        brokerPort,
        brokerUsername,
        brokerPassword,
        hidePassword,
        formKey,
      ];
}
