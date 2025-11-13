import 'package:user_api/user_api.dart';

/// {@template user_repository}
/// User Repository Package
/// {@endtemplate}
class UserRepository {
  /// {@macro user_repository}
  const UserRepository({required IUserApi userApi}) : _userApi = userApi;

  final IUserApi _userApi;

  /// Save language in local storage
  Future<void> saveLanguage({required String language}) =>
      _userApi.saveLanguage(language: language);

  /// Get language from local storage
  String? getLanguage() => _userApi.getLanguage();

  /// Save theme preference in local storage
  Future<void> saveTheme({required String theme}) =>
      _userApi.saveTheme(theme: theme);

  /// Get theme preference from local storage
  String? getTheme() => _userApi.getTheme();

  /// Save base color in local storage
  Future<void> saveBaseColor({required String baseColor}) =>
      _userApi.saveBaseColor(baseColor: baseColor);

  /// Get save color from local storage
  String? getBaseColor() => _userApi.getBaseColor();

  /// Save a group to the box
  Future<void> saveGroup({required GroupModel group}) =>
      _userApi.saveGroup(group: group);

  /// Get all groups in order
  List<GroupModel> getGroups() => _userApi.getGroups();

  /// Update a group by its id
  Future<void> updateGroup({required GroupModel group}) =>
      _userApi.updateGroup(group: group);

  /// Delete a group by its id
  Future<void> deleteGroup({required int groupId}) =>
      _userApi.deleteGroup(groupId: groupId);
}
