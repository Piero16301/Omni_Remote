import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:user_api/user_api.dart';
import 'package:user_api_remote/user_api_remote.dart';
import 'package:uuid/uuid.dart';

/// {@template user_api_remote}
/// User API Remote Package
/// {@endtemplate}
class UserApiRemote implements IUserApi {
  /// {@macro user_api_remote}
  UserApiRemote() {
    _settingsBox = Hive.box(kSettingsBoxName);
    _groupsBox = Hive.box(kGroupsBoxName);
    _devicesBox = Hive.box(kDevicesBoxName);
    _brokerBox = Hive.box(kBrokerBoxName);
  }

  /// Box name for settings
  static const kSettingsBoxName = '__settings__';

  /// Box name for groups
  static const kGroupsBoxName = '__groups__';

  /// Box name for devices
  static const kDevicesBoxName = '__devices__';

  /// Box name for encrypted broker credentials
  static const kBrokerBoxName = '__broker_credentials__';

  /// The key used to store the user's language
  static const kUserLanguage = '__user_language__';

  /// The key used to store the user's theme preference
  static const kUserTheme = '__user_theme__';

  /// The key used to store the user's base color preference
  static const kUserBaseColor = '__user_base_color__';

  /// The key used to store the broker URL
  static const kBrokerUrl = '__broker_url__';

  /// The key used to store the broker port
  static const kBrokerPort = '__broker_port__';

  /// The key used to store the broker username
  static const kBrokerUsername = '__broker_username__';

  /// The key used to store the broker password
  static const kBrokerPassword = '__broker_password__';

  // Hive boxes used in the API
  late final Box<String> _settingsBox;
  late final Box<GroupModel> _groupsBox;
  late final Box<DeviceModel> _devicesBox;
  late final Box<String> _brokerBox;

  /// Initialize and open the settings box
  static Future<void> init() async {
    // Initialize encryption helper
    await EncryptionHelper().init();

    if (!Hive.isBoxOpen(kSettingsBoxName)) {
      await Hive.openBox<String>(kSettingsBoxName);
    }
    if (!Hive.isBoxOpen(kGroupsBoxName)) {
      await Hive.openBox<GroupModel>(kGroupsBoxName);
    }
    if (!Hive.isBoxOpen(kDevicesBoxName)) {
      await Hive.openBox<DeviceModel>(kDevicesBoxName);
    }
    // Open encrypted box for broker credentials
    if (!Hive.isBoxOpen(kBrokerBoxName)) {
      await Hive.openBox<String>(
        kBrokerBoxName,
        encryptionCipher: EncryptionHelper().cipher,
      );
    }
  }

  @override
  Future<void> saveLanguage({required String language}) async {
    await _settingsBox.put(kUserLanguage, language);
  }

  @override
  String? getLanguage() {
    return _settingsBox.get(kUserLanguage);
  }

  @override
  Future<void> saveTheme({required String theme}) async {
    await _settingsBox.put(kUserTheme, theme);
  }

  @override
  String? getTheme() {
    return _settingsBox.get(kUserTheme);
  }

  @override
  Future<void> saveBaseColor({required String baseColor}) async {
    await _settingsBox.put(kUserBaseColor, baseColor);
  }

  @override
  String? getBaseColor() {
    return _settingsBox.get(kUserBaseColor);
  }

  @override
  String? getBrokerUrl() {
    return _brokerBox.get(kBrokerUrl);
  }

  @override
  Future<void> saveBrokerUrl({required String brokerUrl}) async {
    await _brokerBox.put(kBrokerUrl, brokerUrl);
  }

  @override
  String? getBrokerPort() {
    return _brokerBox.get(kBrokerPort);
  }

  @override
  Future<void> saveBrokerPort({required String brokerPort}) async {
    await _brokerBox.put(kBrokerPort, brokerPort);
  }

  @override
  String? getBrokerUsername() {
    return _brokerBox.get(kBrokerUsername);
  }

  @override
  Future<void> saveBrokerUsername({required String brokerUsername}) async {
    await _brokerBox.put(kBrokerUsername, brokerUsername);
  }

  @override
  String? getBrokerPassword() {
    return _brokerBox.get(kBrokerPassword);
  }

  @override
  Future<void> saveBrokerPassword({required String brokerPassword}) async {
    await _brokerBox.put(kBrokerPassword, brokerPassword);
  }

  @override
  ValueListenable<Box<GroupModel>> getGroupsListenable() {
    return _groupsBox.listenable();
  }

  @override
  Future<void> createGroup({required GroupModel group}) async {
    final normalizedName = group.title.toLowerCase().replaceAll(' ', '-');
    final existingGroups = _groupsBox.values.toList();

    final isDuplicate = existingGroups.any(
      (existingGroup) =>
          existingGroup.title.toLowerCase().replaceAll(' ', '-') ==
          normalizedName,
    );

    if (isDuplicate) {
      throw Exception('DUPLICATE_GROUP_NAME');
    }

    const uuid = Uuid();
    final dateTime = DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now());
    final newId = '$dateTime-${uuid.v4()}';
    final groupWithId = group.copyWith(id: newId);
    await _groupsBox.put(newId, groupWithId);
  }

  @override
  List<GroupModel> getGroups() {
    return _groupsBox.values.toList();
  }

  @override
  Future<void> updateGroup({required GroupModel group}) async {
    final normalizedName = group.title.toLowerCase().replaceAll(' ', '-');
    final existingGroups = _groupsBox.values.toList();

    final isDuplicate = existingGroups.any(
      (existingGroup) =>
          existingGroup.id != group.id &&
          existingGroup.title.toLowerCase().replaceAll(' ', '-') ==
              normalizedName,
    );

    if (isDuplicate) {
      throw Exception('DUPLICATE_GROUP_NAME');
    }

    if (_groupsBox.containsKey(group.id)) {
      await _groupsBox.put(group.id, group);
    }
  }

  @override
  Future<void> deleteGroup({required String groupId}) async {
    final groupDevices = _devicesBox.values
        .where((device) => device.groupId == groupId)
        .toList();
    if (groupDevices.isNotEmpty) {
      throw Exception('GROUP_NOT_EMPTY');
    }
    if (_groupsBox.containsKey(groupId)) {
      await _groupsBox.delete(groupId);
    } else {
      throw Exception('GROUP_NOT_FOUND');
    }
  }

  @override
  ValueListenable<Box<DeviceModel>> getDevicesListenable() {
    return _devicesBox.listenable();
  }

  @override
  Future<void> createDevice({required DeviceModel device}) async {
    final groupDevices = _devicesBox.values
        .where((d) => d.groupId == device.groupId)
        .toList();
    final normalizedName = device.title.toLowerCase().replaceAll(' ', '-');

    final isDuplicate = groupDevices.any(
      (existingDevice) =>
          existingDevice.title.toLowerCase().replaceAll(' ', '-') ==
          normalizedName,
    );

    if (isDuplicate) {
      throw Exception('DUPLICATE_DEVICE_NAME');
    }

    const uuid = Uuid();
    final dateTime = DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now());
    final newId = '$dateTime-${uuid.v4()}';
    final deviceWithId = device.copyWith(id: newId);
    await _devicesBox.put(newId, deviceWithId);
  }

  @override
  List<DeviceModel> getDevices() {
    return _devicesBox.values.toList();
  }

  @override
  Future<void> updateDevice({required DeviceModel device}) async {
    final groupDevices = _devicesBox.values
        .where((d) => d.groupId == device.groupId)
        .toList();
    final normalizedName = device.title.toLowerCase().replaceAll(' ', '-');

    final isDuplicate = groupDevices.any(
      (existingDevice) =>
          existingDevice.id != device.id &&
          existingDevice.title.toLowerCase().replaceAll(' ', '-') ==
              normalizedName,
    );

    if (isDuplicate) {
      throw Exception('DUPLICATE_DEVICE_NAME');
    }

    if (_devicesBox.containsKey(device.id)) {
      await _devicesBox.put(device.id, device);
    }
  }

  @override
  Future<void> deleteDevice({required String deviceId}) async {
    if (_devicesBox.containsKey(deviceId)) {
      await _devicesBox.delete(deviceId);
    } else {
      throw Exception('DEVICE_NOT_FOUND');
    }
  }
}
