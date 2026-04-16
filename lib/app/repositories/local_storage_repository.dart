import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:omni_remote/app/app.dart';
import 'package:uuid/uuid.dart';

abstract class LocalStorageRepository {
  static const kUserLanguage = '__user_language__';
  static const kUserTheme = '__user_theme__';
  static const kUserBaseColor = '__user_base_color__';
  static const kUserFontFamily = '__user_font_family__';

  static const kBrokerUrl = '__broker_url__';
  static const kBrokerPort = '__broker_port__';
  static const kBrokerUsername = '__broker_username__';
  static const kBrokerPassword = '__broker_password__';

  Future<void> initialize();
  void saveLanguage({required Locale language});
  Locale? getLanguage();
  void saveTheme({required ThemeMode theme});
  ThemeMode? getTheme();
  void saveBaseColor({required Color baseColor});
  Color? getBaseColor();
  void saveFontFamily({required String fontFamily});
  String? getFontFamily();
  void saveBrokerUrl({required String brokerUrl});
  String? getBrokerUrl();
  void saveBrokerPort({required String brokerPort});
  String? getBrokerPort();
  void saveBrokerUsername({required String brokerUsername});
  String? getBrokerUsername();
  void saveBrokerPassword({required String brokerPassword});
  String? getBrokerPassword();
  ValueListenable<List<GroupModel>> getGroupsListenable();
  void createGroup({required GroupModel group});
  List<GroupModel> getGroups();
  void updateGroup({required GroupModel group});
  void deleteGroup({required String groupId});
  ValueListenable<List<DeviceModel>> getDevicesListenable();
  void createDevice({required DeviceModel device});
  List<DeviceModel> getDevices();
  void updateDevice({required DeviceModel device});
  void deleteDevice({required String deviceId});
}

class MockLocalStorageRepository implements LocalStorageRepository {
  @override
  Future<void> initialize() async {}

  @override
  void saveLanguage({required Locale language}) {}

  @override
  Locale? getLanguage() {
    return const Locale('en', 'US');
  }

  @override
  void saveTheme({required ThemeMode theme}) {}

  @override
  ThemeMode? getTheme() {
    return ThemeMode.light;
  }

  @override
  void saveBaseColor({required Color baseColor}) {}

  @override
  Color? getBaseColor() {
    return Colors.blue;
  }

  @override
  void saveFontFamily({required String fontFamily}) {}

  @override
  String? getFontFamily() {
    return 'default';
  }

  @override
  void createDevice({required DeviceModel device}) {}

  @override
  void createGroup({required GroupModel group}) {}

  @override
  void deleteDevice({required String deviceId}) {}

  @override
  void deleteGroup({required String groupId}) {}

  @override
  String? getBrokerPassword() {
    return '';
  }

  @override
  String? getBrokerPort() {
    return '';
  }

  @override
  String? getBrokerUrl() {
    return '';
  }

  @override
  String? getBrokerUsername() {
    return '';
  }

  @override
  List<DeviceModel> getDevices() {
    return [];
  }

  @override
  ValueListenable<List<DeviceModel>> getDevicesListenable() {
    return ValueNotifier([]);
  }

  @override
  List<GroupModel> getGroups() {
    return [];
  }

  @override
  ValueListenable<List<GroupModel>> getGroupsListenable() {
    return ValueNotifier([]);
  }

  @override
  void saveBrokerPassword({required String brokerPassword}) {}

  @override
  void saveBrokerPort({required String brokerPort}) {}

  @override
  void saveBrokerUrl({required String brokerUrl}) {}

  @override
  void saveBrokerUsername({required String brokerUsername}) {}

  @override
  void updateDevice({required DeviceModel device}) {}

  @override
  void updateGroup({required GroupModel group}) {}
}

class HiveLocalStorageRepository implements LocalStorageRepository {
  HiveLocalStorageRepository();

  static const kSettingsBoxName = '__settings__';
  static const kGroupsBoxName = '__groups__';
  static const kDevicesBoxName = '__devices__';
  static const kBrokerBoxName = '__broker_credentials__';

  late final Box<String> _settingsBox;
  late final Box<GroupModel> _groupsBox;
  late final Box<DeviceModel> _devicesBox;
  late final Box<String> _brokerBox;

  @override
  Future<void> initialize() async {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('hive_initialization');

    try {
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
    } finally {
      performance.stopTrace(trace);
    }
  }

  @override
  void saveLanguage({required Locale language}) {
    final languageString = '${language.languageCode}_${language.countryCode}';
    _settingsBox
        .put(LocalStorageRepository.kUserLanguage, languageString)
        .ignore();
  }

  @override
  Locale? getLanguage() {
    final languageString =
        _settingsBox.get(LocalStorageRepository.kUserLanguage);
    if (languageString == null) {
      return null;
    }
    final languageParts = languageString.split('_');
    return Locale(languageParts.first, languageParts.last);
  }

  @override
  void saveTheme({required ThemeMode theme}) {
    _settingsBox
        .put(
          LocalStorageRepository.kUserTheme,
          ThemeHelper.getThemeName(theme),
        )
        .ignore();
  }

  @override
  ThemeMode? getTheme() {
    final themeString = _settingsBox.get(LocalStorageRepository.kUserTheme);
    if (themeString == null) {
      return null;
    }
    return ThemeHelper.getThemeByName(themeString);
  }

  @override
  void saveBaseColor({required Color baseColor}) {
    _settingsBox
        .put(
          LocalStorageRepository.kUserBaseColor,
          ColorHelper.getColorName(baseColor),
        )
        .ignore();
  }

  @override
  Color? getBaseColor() {
    final baseColorString =
        _settingsBox.get(LocalStorageRepository.kUserBaseColor);
    if (baseColorString == null) {
      return null;
    }
    return ColorHelper.getColorByName(baseColorString);
  }

  @override
  void saveFontFamily({required String fontFamily}) {
    _settingsBox
        .put(
          LocalStorageRepository.kUserFontFamily,
          fontFamily,
        )
        .ignore();
  }

  @override
  String? getFontFamily() {
    return _settingsBox.get(LocalStorageRepository.kUserFontFamily);
  }

  @override
  void saveBrokerUrl({required String brokerUrl}) {
    _brokerBox.put(LocalStorageRepository.kBrokerUrl, brokerUrl).ignore();
  }

  @override
  String? getBrokerUrl() {
    return _brokerBox.get(LocalStorageRepository.kBrokerUrl);
  }

  @override
  void saveBrokerPort({required String brokerPort}) {
    _brokerBox.put(LocalStorageRepository.kBrokerPort, brokerPort).ignore();
  }

  @override
  String? getBrokerPort() {
    return _brokerBox.get(LocalStorageRepository.kBrokerPort);
  }

  @override
  void saveBrokerUsername({required String brokerUsername}) {
    _brokerBox
        .put(LocalStorageRepository.kBrokerUsername, brokerUsername)
        .ignore();
  }

  @override
  String? getBrokerUsername() {
    return _brokerBox.get(LocalStorageRepository.kBrokerUsername);
  }

  @override
  void saveBrokerPassword({required String brokerPassword}) {
    _brokerBox
        .put(LocalStorageRepository.kBrokerPassword, brokerPassword)
        .ignore();
  }

  @override
  String? getBrokerPassword() {
    return _brokerBox.get(LocalStorageRepository.kBrokerPassword);
  }

  @override
  ValueListenable<List<GroupModel>> getGroupsListenable() {
    return _BoxListenable<GroupModel>(_groupsBox.listenable());
  }

  @override
  void createGroup({required GroupModel group}) {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('create_group');
    try {
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
    } finally {
      performance.stopTrace(trace);
    }
  }

  @override
  List<GroupModel> getGroups() {
    return _groupsBox.values.toList();
  }

  @override
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

  @override
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

  @override
  ValueListenable<List<DeviceModel>> getDevicesListenable() {
    return _BoxListenable<DeviceModel>(_devicesBox.listenable());
  }

  @override
  void createDevice({required DeviceModel device}) {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('create_device');
    try {
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
    } finally {
      performance.stopTrace(trace);
    }
  }

  @override
  List<DeviceModel> getDevices() {
    return _devicesBox.values.toList();
  }

  @override
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

  @override
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
