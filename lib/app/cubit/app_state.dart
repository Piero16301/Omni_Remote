part of 'app_cubit.dart';

class AppState extends Equatable {
  const AppState({
    this.language = 'en_US',
    this.darkTheme = false,
    this.baseColor = 'INDIGO',
  });

  final String language;
  final bool darkTheme;
  final String baseColor;

  AppState copyWith({
    String? language,
    bool? darkTheme,
    String? baseColor,
  }) {
    return AppState(
      language: language ?? this.language,
      darkTheme: darkTheme ?? this.darkTheme,
      baseColor: baseColor ?? this.baseColor,
    );
  }

  @override
  List<Object> get props => [
    language,
    darkTheme,
    baseColor,
  ];
}
