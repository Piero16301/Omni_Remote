import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:user_api_remote/user_api_remote.dart';

void main() {
  group('UserApiRemote', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_test_');
      Hive.init(tempDir.path);
      await Hive.openBox<dynamic>('__settings__');
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('can be instantiated', () {
      expect(UserApiRemote(), isNotNull);
    });
  });
}
