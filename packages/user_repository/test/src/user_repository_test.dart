// Not required for test files
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:user_api/user_api.dart';
import 'package:user_repository/user_repository.dart';

class _MockUserApi extends IUserApi {
  const _MockUserApi();

  @override
  String? getBaseColor() => null;

  @override
  bool? getDarkTheme() => null;

  @override
  String? getLanguage() => null;

  @override
  Future<void> saveBaseColor({String baseColor = 'INDIGO'}) async {}

  @override
  Future<void> saveDarkTheme({required bool darkTheme}) async {}

  @override
  Future<void> saveLanguage({String language = 'es_ES'}) async {}
}

void main() {
  group('UserRepository', () {
    test('can be instantiated', () {
      expect(
        UserRepository(userApi: _MockUserApi()),
        isNotNull,
      );
    });
  });
}
