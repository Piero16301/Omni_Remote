import 'package:flutter_test/flutter_test.dart';
import 'package:user_api/user_api.dart';

class _MockUserApi extends IUserApi {
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
  group('UserApi', () {
    test('can be implemented', () {
      expect(_MockUserApi(), isNotNull);
    });
  });
}
