import 'package:user_api/user_api.dart';

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

  /// Save theme preference in local storage
  Future<void> saveTheme({required String theme});

  /// Get theme preference from local storage
  String? getTheme();

  /// Save base color in local storage
  Future<void> saveBaseColor({required String baseColor});

  /// Get base color from local storage
  String? getBaseColor();

  /// Save a group to the box
  Future<void> saveGroup({required GroupModel group});

  /// Get all groups in order
  List<GroupModel> getGroups();

  /// Update a group by its id
  Future<void> updateGroup({required GroupModel group});

  /// Delete a group by its id
  Future<void> deleteGroup({required int groupId});
}
