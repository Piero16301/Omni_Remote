import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:hive/hive.dart';

/// {@template encryption_helper}
/// Helper class to manage encryption for broker credentials
/// using Hive's built-in encryption capabilities
/// {@endtemplate}
class EncryptionHelper {
  /// Get the singleton instance of EncryptionHelper
  factory EncryptionHelper() {
    _instance ??= EncryptionHelper._();
    return _instance!;
  }

  /// {@macro encryption_helper}
  EncryptionHelper._();

  static EncryptionHelper? _instance;
  static const String _keyStorageKey = '__encryption_key__';
  HiveAesCipher? _cipher;

  /// Initialize the encryption helper and generate/retrieve encryption key
  Future<void> init() async {
    if (_cipher != null) return;

    final keyBox = await Hive.openBox<String>('__encryption_keys__');
    var keyString = keyBox.get(_keyStorageKey);

    if (keyString == null) {
      // Generate a new 256-bit encryption key
      final key = _generateSecureKey();
      keyString = base64Url.encode(key);
      await keyBox.put(_keyStorageKey, keyString);
    }

    final key = base64Url.decode(keyString);
    _cipher = HiveAesCipher(key);
  }

  /// Generate a secure 256-bit key
  Uint8List _generateSecureKey() {
    final secureRandom = Random.secure();
    final key = Uint8List(32); // 256 bits
    for (var i = 0; i < 32; i++) {
      key[i] = secureRandom.nextInt(256);
    }
    return key;
  }

  /// Get the cipher for encrypting/decrypting boxes
  HiveAesCipher? get cipher => _cipher;

  /// Check if encryption is initialized
  bool get isInitialized => _cipher != null;
}
