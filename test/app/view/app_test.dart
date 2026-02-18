import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:omni_remote/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App with Hive', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_test_');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('can be instantiated', () {
      expect(const AppPage(), isNotNull);
    });
  });
}
