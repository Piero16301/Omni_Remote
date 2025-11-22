part of 'connection_cubit.dart';

class ConnectionState extends Equatable {
  const ConnectionState({
    this.brokerUrl = '',
    this.brokerPort = '',
    this.brokerUsername = '',
    this.brokerPassword = '',
    this.formKey = const GlobalObjectKey<FormState>('connection_form'),
  });

  final String brokerUrl;
  final String brokerPort;
  final String brokerUsername;
  final String brokerPassword;
  final GlobalKey<FormState> formKey;

  ConnectionState copyWith({
    String? brokerUrl,
    String? brokerPort,
    String? brokerUsername,
    String? brokerPassword,
    GlobalKey<FormState>? formKey,
  }) {
    return ConnectionState(
      brokerUrl: brokerUrl ?? this.brokerUrl,
      brokerPort: brokerPort ?? this.brokerPort,
      brokerUsername: brokerUsername ?? this.brokerUsername,
      brokerPassword: brokerPassword ?? this.brokerPassword,
      formKey: formKey ?? this.formKey,
    );
  }

  @override
  List<Object> get props => [
    brokerUrl,
    brokerPort,
    brokerUsername,
    brokerPassword,
    formKey,
  ];
}
