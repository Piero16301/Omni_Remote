import 'dart:async';

import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
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
  Locale? _language = const Locale('en', 'US');
  ThemeMode? _theme = ThemeMode.light;
  Color? _baseColor = Colors.blue;
  String? _fontFamily = ExpressiveFonts.defaultFont;

  String? _brokerUrl = 'broker.emqx.io';
  String? _brokerPort = '1883';
  String? _brokerUsername = 'omni_mock_user';
  String? _brokerPassword = 'omni_mock_password';

  final List<GroupModel> _groups = <GroupModel>[
    GroupModel(
      id: 'mock-group-living-room',
      title: 'Living Room',
      subtitle: 'Main floor',
      icon: 'LIVING_ROOM',
    ),
    GroupModel(
      id: 'mock-group-bedroom',
      title: 'Bedroom',
      subtitle: 'Master suite',
      icon: 'BEDROOM',
    ),
  ];

  final List<DeviceModel> _devices = <DeviceModel>[
    DeviceModel(
      id: 'mock-device-ceiling-light',
      title: 'Ceiling Light',
      subtitle: 'Main switch',
      icon: 'LIGHT',
      tileType: DeviceTileType.boolean,
      groupId: 'mock-group-living-room',
    ),
    DeviceModel(
      id: 'mock-device-thermostat',
      title: 'Thermostat',
      subtitle: 'Target temperature (°C)',
      icon: 'THERMOSTAT',
      tileType: DeviceTileType.number,
      groupId: 'mock-group-living-room',
      rangeMin: 16,
      rangeMax: 30,
      divisions: 28,
      interval: 0.5,
    ),
    DeviceModel(
      id: 'mock-device-bedside-lamp',
      title: 'Bedside Lamp',
      subtitle: 'Nightstand',
      icon: 'BULB',
      tileType: DeviceTileType.boolean,
      groupId: 'mock-group-bedroom',
    ),
    DeviceModel(
      id: 'mock-device-ceiling-fan',
      title: 'Ceiling Fan',
      subtitle: 'Speed level',
      icon: 'FAN',
      tileType: DeviceTileType.number,
      groupId: 'mock-group-bedroom',
      rangeMax: 5,
      divisions: 5,
      interval: 1,
    ),
  ];

  late final ValueNotifier<List<GroupModel>> _groupsNotifier =
      ValueNotifier<List<GroupModel>>(List<GroupModel>.unmodifiable(_groups));
  late final ValueNotifier<List<DeviceModel>> _devicesNotifier =
      ValueNotifier<List<DeviceModel>>(
        List<DeviceModel>.unmodifiable(_devices),
      );

  @override
  Future<void> initialize() async {}

  @override
  void saveLanguage({required Locale language}) {
    _language = language;
  }

  @override
  Locale? getLanguage() => _language;

  @override
  void saveTheme({required ThemeMode theme}) {
    _theme = theme;
  }

  @override
  ThemeMode? getTheme() => _theme;

  @override
  void saveBaseColor({required Color baseColor}) {
    _baseColor = baseColor;
  }

  @override
  Color? getBaseColor() => _baseColor;

  @override
  void saveFontFamily({required String fontFamily}) {
    _fontFamily = fontFamily;
  }

  @override
  String? getFontFamily() => _fontFamily;

  @override
  void saveBrokerUrl({required String brokerUrl}) {
    _brokerUrl = brokerUrl;
  }

  @override
  String? getBrokerUrl() => _brokerUrl;

  @override
  void saveBrokerPort({required String brokerPort}) {
    _brokerPort = brokerPort;
  }

  @override
  String? getBrokerPort() => _brokerPort;

  @override
  void saveBrokerUsername({required String brokerUsername}) {
    _brokerUsername = brokerUsername;
  }

  @override
  String? getBrokerUsername() => _brokerUsername;

  @override
  void saveBrokerPassword({required String brokerPassword}) {
    _brokerPassword = brokerPassword;
  }

  @override
  String? getBrokerPassword() => _brokerPassword;

  @override
  ValueListenable<List<GroupModel>> getGroupsListenable() => _groupsNotifier;

  @override
  void createGroup({required GroupModel group}) {
    final normalizedName = group.title.toLowerCase().replaceAll(' ', '-');
    final isDuplicate = _groups.any(
      (existingGroup) =>
          existingGroup.title.toLowerCase().replaceAll(' ', '-') ==
          normalizedName,
    );
    if (isDuplicate) {
      throw Exception('DUPLICATE_GROUP_NAME');
    }

    final newId = group.id.isNotEmpty
        ? group.id
        : 'mock-group-${const Uuid().v4()}';
    _groups.add(group.copyWith(id: newId));
    _groupsNotifier.value = List<GroupModel>.unmodifiable(_groups);
  }

  @override
  List<GroupModel> getGroups() => List<GroupModel>.unmodifiable(_groups);

  @override
  void updateGroup({required GroupModel group}) {
    final normalizedName = group.title.toLowerCase().replaceAll(' ', '-');
    final isDuplicate = _groups.any(
      (existingGroup) =>
          existingGroup.id != group.id &&
          existingGroup.title.toLowerCase().replaceAll(' ', '-') ==
              normalizedName,
    );
    if (isDuplicate) {
      throw Exception('DUPLICATE_GROUP_NAME');
    }

    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = group;
      _groupsNotifier.value = List<GroupModel>.unmodifiable(_groups);
    }
  }

  @override
  void deleteGroup({required String groupId}) {
    final hasDevices = _devices.any((device) => device.groupId == groupId);
    if (hasDevices) {
      throw Exception('GROUP_NOT_EMPTY');
    }

    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index == -1) {
      throw Exception('GROUP_NOT_FOUND');
    }

    _groups.removeAt(index);
    _groupsNotifier.value = List<GroupModel>.unmodifiable(_groups);
  }

  @override
  ValueListenable<List<DeviceModel>> getDevicesListenable() => _devicesNotifier;

  @override
  void createDevice({required DeviceModel device}) {
    final normalizedName = device.title.toLowerCase().replaceAll(' ', '-');
    final isDuplicate = _devices.any(
      (existingDevice) =>
          existingDevice.groupId == device.groupId &&
          existingDevice.title.toLowerCase().replaceAll(' ', '-') ==
              normalizedName,
    );
    if (isDuplicate) {
      throw Exception('DUPLICATE_DEVICE_NAME');
    }

    final newId = device.id.isNotEmpty
        ? device.id
        : 'mock-device-${const Uuid().v4()}';
    _devices.add(device.copyWith(id: newId));
    _devicesNotifier.value = List<DeviceModel>.unmodifiable(_devices);
  }

  @override
  List<DeviceModel> getDevices() => List<DeviceModel>.unmodifiable(_devices);

  @override
  void updateDevice({required DeviceModel device}) {
    final normalizedName = device.title.toLowerCase().replaceAll(' ', '-');
    final isDuplicate = _devices.any(
      (existingDevice) =>
          existingDevice.groupId == device.groupId &&
          existingDevice.id != device.id &&
          existingDevice.title.toLowerCase().replaceAll(' ', '-') ==
              normalizedName,
    );
    if (isDuplicate) {
      throw Exception('DUPLICATE_DEVICE_NAME');
    }

    final index = _devices.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      _devices[index] = device;
      _devicesNotifier.value = List<DeviceModel>.unmodifiable(_devices);
    }
  }

  @override
  void deleteDevice({required String deviceId}) {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index == -1) {
      throw Exception('DEVICE_NOT_FOUND');
    }

    _devices.removeAt(index);
    _devicesNotifier.value = List<DeviceModel>.unmodifiable(_devices);
  }
}

class HiveLocalStorageRepository implements LocalStorageRepository {
  new();

  static const kSettingsBoxName = '__settings__';
  static const kGroupsBoxName = '__groups__';
  static const kDevicesBoxName = '__devices__';
  static const kBrokerBoxName = '__broker_credentials__';

  late final Box<String> _settingsBox;
  late final Box<GroupModel> _groupsBox;
  late final Box<DeviceModel> _devicesBox;
  late final Box<String> _brokerBox;

  void _persist(Future<void> future, String reason) {
    unawaited(
      future.catchError((Object error, StackTrace stackTrace) {
        if (getIt.isRegistered<CrashService>()) {
          getIt<CrashService>().recordError(error, stackTrace, reason: reason);
        }
      }),
    );
  }

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
    _persist(
      _settingsBox.put(LocalStorageRepository.kUserLanguage, languageString),
      'Failed to save language',
    );
  }

  @override
  Locale? getLanguage() {
    final languageString = _settingsBox.get(
      LocalStorageRepository.kUserLanguage,
    );
    if (languageString == null) {
      return null;
    }
    return ExpressiveLanguages.fromLanguageCode(languageString);
  }

  @override
  void saveTheme({required ThemeMode theme}) {
    _persist(
      _settingsBox.put(
        LocalStorageRepository.kUserTheme,
        ExpressiveTheme.toKey(theme),
      ),
      'Failed to save theme',
    );
  }

  @override
  ThemeMode? getTheme() {
    final themeString = _settingsBox.get(LocalStorageRepository.kUserTheme);
    if (themeString == null) {
      return null;
    }
    return ExpressiveTheme.fromKey(themeString);
  }

  @override
  void saveBaseColor({required Color baseColor}) {
    _persist(
      _settingsBox.put(
        LocalStorageRepository.kUserBaseColor,
        ExpressiveColors.toKey(baseColor),
      ),
      'Failed to save baseColor',
    );
  }

  @override
  Color? getBaseColor() {
    final baseColorString = _settingsBox.get(
      LocalStorageRepository.kUserBaseColor,
    );
    if (baseColorString == null) {
      return null;
    }
    return ExpressiveColors.fromKey(baseColorString);
  }

  @override
  void saveFontFamily({required String fontFamily}) {
    _persist(
      _settingsBox.put(LocalStorageRepository.kUserFontFamily, fontFamily),
      'Failed to save fontFamily',
    );
  }

  @override
  String? getFontFamily() {
    return _settingsBox.get(LocalStorageRepository.kUserFontFamily);
  }

  @override
  void saveBrokerUrl({required String brokerUrl}) {
    _persist(
      _brokerBox.put(LocalStorageRepository.kBrokerUrl, brokerUrl),
      'Failed to save brokerUrl',
    );
  }

  @override
  String? getBrokerUrl() {
    return _brokerBox.get(LocalStorageRepository.kBrokerUrl);
  }

  @override
  void saveBrokerPort({required String brokerPort}) {
    _persist(
      _brokerBox.put(LocalStorageRepository.kBrokerPort, brokerPort),
      'Failed to save brokerPort',
    );
  }

  @override
  String? getBrokerPort() {
    return _brokerBox.get(LocalStorageRepository.kBrokerPort);
  }

  @override
  void saveBrokerUsername({required String brokerUsername}) {
    _persist(
      _brokerBox.put(LocalStorageRepository.kBrokerUsername, brokerUsername),
      'Failed to save brokerUsername',
    );
  }

  @override
  String? getBrokerUsername() {
    return _brokerBox.get(LocalStorageRepository.kBrokerUsername);
  }

  @override
  void saveBrokerPassword({required String brokerPassword}) {
    _persist(
      _brokerBox.put(LocalStorageRepository.kBrokerPassword, brokerPassword),
      'Failed to save brokerPassword',
    );
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
      _persist(_groupsBox.put(newId, groupWithId), 'Failed to create group');
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
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('update_group');
    try {
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
        _persist(_groupsBox.put(group.id, group), 'Failed to update group');
      }
    } finally {
      performance.stopTrace(trace);
    }
  }

  @override
  void deleteGroup({required String groupId}) {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('delete_group');
    try {
      final groupDevices = _devicesBox.values
          .where((device) => device.groupId == groupId)
          .toList();
      if (groupDevices.isNotEmpty) {
        throw Exception('GROUP_NOT_EMPTY');
      }
      if (_groupsBox.containsKey(groupId)) {
        _persist(_groupsBox.delete(groupId), 'Failed to delete group');
      } else {
        throw Exception('GROUP_NOT_FOUND');
      }
    } finally {
      performance.stopTrace(trace);
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
      _persist(_devicesBox.put(newId, deviceWithId), 'Failed to create device');
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
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('update_device');
    try {
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
        _persist(_devicesBox.put(device.id, device), 'Failed to update device');
      }
    } finally {
      performance.stopTrace(trace);
    }
  }

  @override
  void deleteDevice({required String deviceId}) {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('delete_device');
    try {
      if (_devicesBox.containsKey(deviceId)) {
        _persist(_devicesBox.delete(deviceId), 'Failed to delete device');
      } else {
        throw Exception('DEVICE_NOT_FOUND');
      }
    } finally {
      performance.stopTrace(trace);
    }
  }
}

class _BoxListenable<T> extends ValueListenable<List<T>> {
  new(this._listenable);

  final ValueListenable<Box<T>> _listenable;

  @override
  void addListener(VoidCallback listener) => _listenable.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _listenable.removeListener(listener);

  @override
  List<T> get value => _listenable.value.values.toList();
}
