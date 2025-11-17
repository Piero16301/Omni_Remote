import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:user_api/user_api.dart';

class _MockUserApi extends IUserApi {
  @override
  String? getBaseColor() => null;

  @override
  String? getTheme() => null;

  @override
  String? getLanguage() => null;

  @override
  Future<void> saveBaseColor({String baseColor = 'INDIGO'}) async {}

  @override
  Future<void> saveTheme({String theme = 'DARK'}) async {}

  @override
  Future<void> saveLanguage({String language = 'es_ES'}) async {}

  @override
  ValueListenable<Box<GroupModel>> getGroupsListenable() {
    throw UnimplementedError();
  }

  @override
  Future<void> createGroup({required GroupModel group}) async {}

  @override
  List<GroupModel> getGroups() => [];

  @override
  Future<void> updateGroup({required GroupModel group}) async {}

  @override
  Future<void> deleteGroup({required String groupId}) async {}
}

void main() {
  group('UserApi', () {
    test('can be implemented', () {
      expect(_MockUserApi(), isNotNull);
    });
  });
}
