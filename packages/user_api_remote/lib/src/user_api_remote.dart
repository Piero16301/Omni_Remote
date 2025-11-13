import 'package:hive/hive.dart';
import 'package:user_api/user_api.dart';

/// {@template user_api_remote}
/// User API Remote Package
/// {@endtemplate}
class UserApiRemote implements IUserApi {
  /// {@macro user_api_remote}
  UserApiRemote() {
    _settingsBox = Hive.box(kSettingsBoxName);
    _groupsBox = Hive.box(kGroupsBoxName);
  }

  /// Box name for settings
  static const kSettingsBoxName = '__settings__';

  /// Box name for groups
  static const kGroupsBoxName = '__groups__';

  /// The key used to store the user's language
  static const kUserLanguage = '__user_language__';

  /// The key used to store the user's theme preference
  static const kUserTheme = '__user_theme__';

  /// The key used to store the user's base color preference
  static const kUserBaseColor = '__user_base_color__';

  // Hive boxes used in the API
  late final Box<String> _settingsBox;
  late final Box<GroupModel> _groupsBox;

  /// Initialize and open the settings box
  static Future<void> init() async {
    if (!Hive.isBoxOpen(kSettingsBoxName)) {
      await Hive.openBox<String>(kSettingsBoxName);
    }
    if (!Hive.isBoxOpen(kGroupsBoxName)) {
      await Hive.openBox<dynamic>(kGroupsBoxName);
    }
  }

  @override
  Future<void> saveLanguage({required String language}) async {
    await _settingsBox.put(kUserLanguage, language);
  }

  @override
  String? getLanguage() {
    return _settingsBox.get(kUserLanguage);
  }

  @override
  Future<void> saveTheme({required String theme}) async {
    await _settingsBox.put(kUserTheme, theme);
  }

  @override
  String? getTheme() {
    return _settingsBox.get(kUserTheme);
  }

  @override
  Future<void> saveBaseColor({required String baseColor}) async {
    await _settingsBox.put(kUserBaseColor, baseColor);
  }

  @override
  String? getBaseColor() {
    return _settingsBox.get(kUserBaseColor);
  }

  @override
  Future<void> saveGroup({required GroupModel group}) async {
    final index = await _groupsBox.add(group);
    await _groupsBox.putAt(index, group.copyWith(id: index));
  }

  @override
  List<GroupModel> getGroups() {
    return _groupsBox.values.toList();
  }

  @override
  Future<void> updateGroup({required GroupModel group}) async {
    if (group.id >= 0 && group.id < _groupsBox.length) {
      await _groupsBox.putAt(group.id, group);
    }
  }

  @override
  Future<void> deleteGroup({required int groupId}) async {
    if (groupId >= 0 && groupId < _groupsBox.length) {
      await _groupsBox.deleteAt(groupId);
    }
  }
}
