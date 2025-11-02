/// {@template user_api}
/// User API Package
/// {@endtemplate}
abstract class IUserApi {
  /// {@macro user_api}
  const IUserApi();

  /// Save language in local storage
  Future<void> saveLanguage({required String language});

  /// Get language from local storage
  String? getLanguage();

  /// Save dark theme preference in local storage
  Future<void> saveDarkTheme({required bool darkTheme});

  /// Get dark theme preference from local storage
  bool? getDarkTheme();

  /// Save base color in local storage
  Future<void> saveBaseColor({required String baseColor});

  /// Get base color from local storage
  String? getBaseColor();
}
