import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_api/user_api.dart';

/// {@template user_api_remote}
/// User API Remote Package
/// {@endtemplate}
class UserApiRemote implements IUserApi {
  /// {@macro user_api_remote}
  UserApiRemote({required SharedPreferences preferences})
    : _preferences = preferences;

  /// The key used to store the user's language
  static const kUserLanguage = '__user_language__';

  /// The key used to store the user's dark theme preference
  static const kUserDarkTheme = '__user_dark_theme__';

  /// The key used to store the user's base color preference
  static const kUserBaseColor = '__user_base_color__';

  final SharedPreferences _preferences;

  @override
  Future<void> saveLanguage({required String language}) async {
    await _preferences.setString(kUserLanguage, language);
  }

  @override
  String? getLanguage() {
    return _preferences.getString(kUserLanguage);
  }

  @override
  Future<void> saveDarkTheme({required bool darkTheme}) async {
    await _preferences.setBool(kUserDarkTheme, darkTheme);
  }

  @override
  bool? getDarkTheme() {
    return _preferences.getBool(kUserDarkTheme);
  }

  @override
  Future<void> saveBaseColor({required String baseColor}) async {
    await _preferences.setString(kUserBaseColor, baseColor);
  }

  @override
  String? getBaseColor() {
    return _preferences.getString(kUserBaseColor);
  }
}
