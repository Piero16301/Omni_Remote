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
  String? getFontFamily() => null;

  @override
  Future<void> saveBaseColor({String baseColor = 'INDIGO'}) async {}

  @override
  Future<void> saveTheme({String theme = 'DARK'}) async {}

  @override
  Future<void> saveLanguage({String language = 'es_ES'}) async {}

  @override
  Future<void> saveFontFamily({String fontFamily = 'Roboto_regular'}) async {}

  @override
  String? getBrokerUrl() => null;

  @override
  Future<void> saveBrokerUrl({required String brokerUrl}) async {}

  @override
  String? getBrokerPort() => null;

  @override
  Future<void> saveBrokerPort({required String brokerPort}) async {}

  @override
  String? getBrokerUsername() => null;

  @override
  Future<void> saveBrokerUsername({required String brokerUsername}) async {}

  @override
  String? getBrokerPassword() => null;

  @override
  Future<void> saveBrokerPassword({required String brokerPassword}) async {}

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

  @override
  ValueListenable<Box<DeviceModel>> getDevicesListenable() {
    throw UnimplementedError();
  }

  @override
  Future<void> createDevice({required DeviceModel device}) async {}

  @override
  List<DeviceModel> getDevices() => [];

  @override
  Future<void> updateDevice({required DeviceModel device}) async {}

  @override
  Future<void> deleteDevice({required String deviceId}) async {}
}

void main() {
  group('UserApi', () {
    test('can be implemented', () {
      expect(_MockUserApi(), isNotNull);
    });
  });
}
