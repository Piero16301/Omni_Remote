import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:omni_remote/app/app.dart';
import 'package:uuid/uuid.dart';

class LocalStorageService {
  LocalStorageService();

  static const kSettingsBoxName = '__settings__';
  static const kGroupsBoxName = '__groups__';
  static const kDevicesBoxName = '__devices__';
  static const kBrokerBoxName = '__broker_credentials__';

  static const kUserLanguage = '__user_language__';
  static const kUserTheme = '__user_theme__';
  static const kUserBaseColor = '__user_base_color__';
  static const kUserFontFamily = '__user_font_family__';

  static const kBrokerUrl = '__broker_url__';
  static const kBrokerPort = '__broker_port__';
  static const kBrokerUsername = '__broker_username__';
  static const kBrokerPassword = '__broker_password__';

  late final Box<String> _settingsBox;
  late final Box<GroupModel> _groupsBox;
  late final Box<DeviceModel> _devicesBox;
  late final Box<String> _brokerBox;

  Future<void> initialize() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(GroupModelAdapter().typeId)) {
      Hive.registerAdapter(GroupModelAdapter());
    }
    if (!Hive.isAdapterRegistered(DeviceModelAdapter().typeId)) {
      Hive.registerAdapter(DeviceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(DeviceTileTypeAdapter().typeId)) {
      Hive.registerAdapter(DeviceTileTypeAdapter());
    }

    // Initialize encryption helper
    await EncryptionHelper().init();

    if (!Hive.isBoxOpen(kSettingsBoxName)) {
      await Hive.openBox<String>(kSettingsBoxName);
    }
    _settingsBox = Hive.box(kSettingsBoxName);

    if (!Hive.isBoxOpen(kGroupsBoxName)) {
      await Hive.openBox<GroupModel>(kGroupsBoxName);
    }
    _groupsBox = Hive.box(kGroupsBoxName);

    if (!Hive.isBoxOpen(kDevicesBoxName)) {
      await Hive.openBox<DeviceModel>(kDevicesBoxName);
    }
    _devicesBox = Hive.box(kDevicesBoxName);

    // Open encrypted box for broker credentials
    if (!Hive.isBoxOpen(kBrokerBoxName)) {
      await Hive.openBox<String>(
        kBrokerBoxName,
        encryptionCipher: EncryptionHelper().cipher,
      );
    }
    _brokerBox = Hive.box(kBrokerBoxName);
  }

  void saveLanguage({required Locale language}) {
    final languageString = '${language.languageCode}_${language.countryCode}';
    _settingsBox.put(kUserLanguage, languageString).ignore();
  }

  Locale? getLanguage() {
    final languageString = _settingsBox.get(kUserLanguage);
    if (languageString == null) {
      return null;
    }
    final languageParts = languageString.split('_');
    return Locale(languageParts.first, languageParts.last);
  }

  void saveTheme({required ThemeMode theme}) {
    _settingsBox.put(kUserTheme, ThemeHelper.getThemeName(theme)).ignore();
  }

  ThemeMode? getTheme() {
    final themeString = _settingsBox.get(kUserTheme);
    if (themeString == null) {
      return null;
    }
    return ThemeHelper.getThemeByName(themeString);
  }

  void saveBaseColor({required Color baseColor}) {
    _settingsBox
        .put(kUserBaseColor, ColorHelper.getColorName(baseColor))
        .ignore();
  }

  Color? getBaseColor() {
    final baseColorString = _settingsBox.get(kUserBaseColor);
    if (baseColorString == null) {
      return null;
    }
    return ColorHelper.getColorByName(baseColorString);
  }

  void saveFontFamily({required String fontFamily}) {
    _settingsBox.put(kUserFontFamily, fontFamily).ignore();
  }

  String? getFontFamily() {
    return _settingsBox.get(kUserFontFamily);
  }

  void saveBrokerUrl({required String brokerUrl}) {
    _brokerBox.put(kBrokerUrl, brokerUrl).ignore();
  }

  String? getBrokerUrl() {
    return _brokerBox.get(kBrokerUrl);
  }

  void saveBrokerPort({required String brokerPort}) {
    _brokerBox.put(kBrokerPort, brokerPort).ignore();
  }

  String? getBrokerPort() {
    return _brokerBox.get(kBrokerPort);
  }

  void saveBrokerUsername({required String brokerUsername}) {
    _brokerBox.put(kBrokerUsername, brokerUsername).ignore();
  }

  String? getBrokerUsername() {
    return _brokerBox.get(kBrokerUsername);
  }

  void saveBrokerPassword({required String brokerPassword}) {
    _brokerBox.put(kBrokerPassword, brokerPassword).ignore();
  }

  String? getBrokerPassword() {
    return _brokerBox.get(kBrokerPassword);
  }

  ValueListenable<List<GroupModel>> getGroupsListenable() {
    return _BoxListenable<GroupModel>(_groupsBox.listenable());
  }

  void createGroup({required GroupModel group}) {
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
    _groupsBox.put(newId, groupWithId).ignore();
  }

  List<GroupModel> getGroups() {
    return _groupsBox.values.toList();
  }

  void updateGroup({required GroupModel group}) {
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
      _groupsBox.put(group.id, group).ignore();
    }
  }

  void deleteGroup({required String groupId}) {
    final groupDevices = _devicesBox.values
        .where((device) => device.groupId == groupId)
        .toList();
    if (groupDevices.isNotEmpty) {
      throw Exception('GROUP_NOT_EMPTY');
    }
    if (_groupsBox.containsKey(groupId)) {
      _groupsBox.delete(groupId).ignore();
    } else {
      throw Exception('GROUP_NOT_FOUND');
    }
  }

  ValueListenable<List<DeviceModel>> getDevicesListenable() {
    return _BoxListenable<DeviceModel>(_devicesBox.listenable());
  }

  void createDevice({required DeviceModel device}) {
    final groupDevices =
        _devicesBox.values.where((d) => d.groupId == device.groupId).toList();
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
    _devicesBox.put(newId, deviceWithId).ignore();
  }

  List<DeviceModel> getDevices() {
    return _devicesBox.values.toList();
  }

  void updateDevice({required DeviceModel device}) {
    final groupDevices =
        _devicesBox.values.where((d) => d.groupId == device.groupId).toList();
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
      _devicesBox.put(device.id, device).ignore();
    }
  }

  void deleteDevice({required String deviceId}) {
    if (_devicesBox.containsKey(deviceId)) {
      _devicesBox.delete(deviceId).ignore();
    } else {
      throw Exception('DEVICE_NOT_FOUND');
    }
  }
}

class _BoxListenable<T> extends ValueListenable<List<T>> {
  _BoxListenable(this._listenable);

  final ValueListenable<Box<T>> _listenable;

  @override
  void addListener(VoidCallback listener) => _listenable.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _listenable.removeListener(listener);

  @override
  List<T> get value => _listenable.value.values.toList();
}
