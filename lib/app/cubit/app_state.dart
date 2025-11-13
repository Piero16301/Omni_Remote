part of 'app_cubit.dart';

class AppState extends Equatable {
  const AppState({
    this.language = 'en_US',
    this.theme = 'LIGHT',
    this.baseColor = 'INDIGO',
  });

  final String language;
  final String theme;
  final String baseColor;

  AppState copyWith({
    String? language,
    String? theme,
    String? baseColor,
  }) {
    return AppState(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      baseColor: baseColor ?? this.baseColor,
    );
  }

  @override
  List<Object> get props => [
    language,
    theme,
    baseColor,
  ];
}
