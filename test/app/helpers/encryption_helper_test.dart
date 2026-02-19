import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:omni_remote/app/helpers/encryption_helper.dart';

void main() {
  group('EncryptionHelper', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = Directory.systemTemp.createTempSync('hive_crypto_test');
      Hive.init(tempDir.path);
    });

    tearDownAll(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('singleton instance returns the same object', () {
      final helper1 = EncryptionHelper();
      final helper2 = EncryptionHelper();
      expect(identical(helper1, helper2), isTrue);
    });

    test('initializes and creates cipher successfully', () async {
      final helper = EncryptionHelper();

      // Before init, it might be false (or true if previous tests ran in same
      // memory space). Since it's a singleton, we just ensure init works and
      // cipher is created.
      await helper.init();

      expect(helper.isInitialized, isTrue);
      expect(helper.cipher, isNotNull);
      expect(helper.cipher, isA<HiveAesCipher>());
    });
  });
}
