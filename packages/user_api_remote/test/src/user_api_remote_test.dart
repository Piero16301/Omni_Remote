import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_api_remote/user_api_remote.dart';

void main() {
  group('UserApiRemote', () {
    test('can be instantiated', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      expect(UserApiRemote(preferences: preferences), isNotNull);
    });
  });
}
