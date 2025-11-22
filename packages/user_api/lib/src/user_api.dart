import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:user_api/user_api.dart';

/// {@template user_api}
/// User API Package
/// {@endtemplate}
abstract class IUserApi {
  /// {@macro user_api}
  const IUserApi();

  /// Save language in local storage
  Future<void> saveLanguage({required String language});

  /// Get language from local storage
  String? getLanguage();

  /// Save theme preference in local storage
  Future<void> saveTheme({required String theme});

  /// Get theme preference from local storage
  String? getTheme();

  /// Save base color in local storage
  Future<void> saveBaseColor({required String baseColor});

  /// Get base color from local storage
  String? getBaseColor();

  /// Get Broker URL
  String? getBrokerUrl();

  /// Save Broker URL
  Future<void> saveBrokerUrl({required String brokerUrl});

  /// Get Broker Port
  String? getBrokerPort();

  /// Save Broker Port
  Future<void> saveBrokerPort({required String brokerPort});

  /// Get Broker Username
  String? getBrokerUsername();

  /// Save Broker Username
  Future<void> saveBrokerUsername({required String brokerUsername});

  /// Get Broker Password
  String? getBrokerPassword();

  /// Save Broker Password
  Future<void> saveBrokerPassword({required String brokerPassword});

  /// Get a ValueListenable for groups box
  ValueListenable<Box<GroupModel>> getGroupsListenable();

  /// Create a group to the box
  Future<void> createGroup({required GroupModel group});

  /// Get all groups in order
  List<GroupModel> getGroups();

  /// Update a group by its id
  Future<void> updateGroup({required GroupModel group});

  /// Delete a group by its id
  Future<void> deleteGroup({required String groupId});

  /// Get a ValueListenable for devices box
  ValueListenable<Box<DeviceModel>> getDevicesListenable();

  /// Create a device to the box
  Future<void> createDevice({required DeviceModel device});

  /// Get all devices in order
  List<DeviceModel> getDevices();

  /// Update a device by its id
  Future<void> updateDevice({required DeviceModel device});

  /// Delete a device by its id
  Future<void> deleteDevice({required String deviceId});
}
