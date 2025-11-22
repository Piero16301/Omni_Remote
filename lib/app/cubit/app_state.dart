part of 'app_cubit.dart';

enum BrokerConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

class AppState extends Equatable {
  const AppState({
    this.language = 'en_US',
    this.theme = 'LIGHT',
    this.baseColor = 'INDIGO',
    this.brokerConnectionStatus = BrokerConnectionStatus.disconnected,
  });

  final String language;
  final String theme;
  final String baseColor;
  final BrokerConnectionStatus brokerConnectionStatus;

  AppState copyWith({
    String? language,
    String? theme,
    String? baseColor,
    BrokerConnectionStatus? brokerConnectionStatus,
  }) {
    return AppState(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      baseColor: baseColor ?? this.baseColor,
      brokerConnectionStatus:
          brokerConnectionStatus ?? this.brokerConnectionStatus,
    );
  }

  @override
  List<Object?> get props => [
    language,
    theme,
    baseColor,
    brokerConnectionStatus,
  ];
}
