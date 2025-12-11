part of 'app_cubit.dart';

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

class AppState extends Equatable {
  const AppState({
    this.language = 'en_US',
    this.theme = 'LIGHT',
    this.baseColor = 'INDIGO',
    this.fontFamily = 'Nunito_regular',
    this.brokerConnectionStatus = BrokerConnectionStatus.disconnected,
  });

  final String language;
  final String theme;
  final String baseColor;
  final String fontFamily;
  final BrokerConnectionStatus brokerConnectionStatus;

  AppState copyWith({
    String? language,
    String? theme,
    String? baseColor,
    String? fontFamily,
    BrokerConnectionStatus? brokerConnectionStatus,
  }) {
    return AppState(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      baseColor: baseColor ?? this.baseColor,
      fontFamily: fontFamily ?? this.fontFamily,
      brokerConnectionStatus:
          brokerConnectionStatus ?? this.brokerConnectionStatus,
    );
  }

  @override
  List<Object?> get props => [
        language,
        theme,
        baseColor,
        fontFamily,
        brokerConnectionStatus,
      ];
}
