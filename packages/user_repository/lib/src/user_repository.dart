import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:user_api/user_api.dart';

/// {@template user_repository}
/// User Repository Package
/// {@endtemplate}
class UserRepository {
  /// {@macro user_repository}
  const UserRepository({required IUserApi userApi}) : _userApi = userApi;

  final IUserApi _userApi;

  /// Save language in local storage
  Future<void> saveLanguage({required String language}) =>
      _userApi.saveLanguage(language: language);

  /// Get language from local storage
  String? getLanguage() => _userApi.getLanguage();

  /// Save theme preference in local storage
  Future<void> saveTheme({required String theme}) =>
      _userApi.saveTheme(theme: theme);

  /// Get theme preference from local storage
  String? getTheme() => _userApi.getTheme();

  /// Save base color in local storage
  Future<void> saveBaseColor({required String baseColor}) =>
      _userApi.saveBaseColor(baseColor: baseColor);

  /// Get save color from local storage
  String? getBaseColor() => _userApi.getBaseColor();

  /// Save font family in local storage
  Future<void> saveFontFamily({required String fontFamily}) =>
      _userApi.saveFontFamily(fontFamily: fontFamily);

  /// Get font family from local storage
  String? getFontFamily() => _userApi.getFontFamily();

  /// Get Broker URL
  String? getBrokerUrl() => _userApi.getBrokerUrl();

  /// Save Broker URL
  Future<void> saveBrokerUrl({required String brokerUrl}) =>
      _userApi.saveBrokerUrl(brokerUrl: brokerUrl);

  /// Get Broker Port
  String? getBrokerPort() => _userApi.getBrokerPort();

  /// Save Broker Port
  Future<void> saveBrokerPort({required String brokerPort}) =>
      _userApi.saveBrokerPort(brokerPort: brokerPort);

  /// Get Broker Username
  String? getBrokerUsername() => _userApi.getBrokerUsername();

  /// Save Broker Username
  Future<void> saveBrokerUsername({required String brokerUsername}) =>
      _userApi.saveBrokerUsername(brokerUsername: brokerUsername);

  /// Get Broker Password
  String? getBrokerPassword() => _userApi.getBrokerPassword();

  /// Save Broker Password
  Future<void> saveBrokerPassword({required String brokerPassword}) =>
      _userApi.saveBrokerPassword(brokerPassword: brokerPassword);

  /// Get a ValueListenable for groups box
  ValueListenable<Box<GroupModel>> getGroupsListenable() =>
      _userApi.getGroupsListenable();

  /// Create a group to the box
  Future<void> createGroup({required GroupModel group}) =>
      _userApi.createGroup(group: group);

  /// Get all groups in order
  List<GroupModel> getGroups() => _userApi.getGroups();

  /// Update a group by its id
  Future<void> updateGroup({required GroupModel group}) =>
      _userApi.updateGroup(group: group);

  /// Delete a group by its id
  Future<void> deleteGroup({required String groupId}) =>
      _userApi.deleteGroup(groupId: groupId);

  /// Get a ValueListenable for devices box
  ValueListenable<Box<DeviceModel>> getDevicesListenable() =>
      _userApi.getDevicesListenable();

  /// Create a device to the box
  Future<void> createDevice({required DeviceModel device}) =>
      _userApi.createDevice(device: device);

  /// Get all devices in order
  List<DeviceModel> getDevices() => _userApi.getDevices();

  /// Update a device by its id
  Future<void> updateDevice({required DeviceModel device}) =>
      _userApi.updateDevice(device: device);

  /// Delete a device by its id
  Future<void> deleteDevice({required String deviceId}) =>
      _userApi.deleteDevice(deviceId: deviceId);
}
