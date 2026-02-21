import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:omni_remote/app/app.dart';

void main() {
  group('LocalStorageService', () {
    late LocalStorageService service;
    late Directory tempDir;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = Directory.systemTemp.createTempSync('hive_local_storage_test');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/path_provider'),
              (methodCall) async {
        return tempDir.path;
      });

      service = LocalStorageService();
      await service.initialize();
    });

    tearDownAll(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('saves and gets language', () {
      service.saveLanguage(language: const Locale('es', 'ES'));
      final lang = service.getLanguage();
      expect(lang?.languageCode, 'es');
      expect(lang?.countryCode, 'ES');
    });

    test('saves and gets theme', () {
      service.saveTheme(theme: ThemeMode.dark);
      expect(service.getTheme(), ThemeMode.dark);
    });

    test('saves and gets broker url', () {
      service.saveBrokerUrl(brokerUrl: 'tcp://broker.hivemq.com');
      expect(service.getBrokerUrl(), 'tcp://broker.hivemq.com');
    });

    test('saves and gets broker port', () {
      service.saveBrokerPort(brokerPort: '1883');
      expect(service.getBrokerPort(), '1883');
    });

    test('saves and gets broker username', () {
      service.saveBrokerUsername(brokerUsername: 'user123');
      expect(service.getBrokerUsername(), 'user123');
    });

    test('saves and gets broker password', () {
      service.saveBrokerPassword(brokerPassword: 'pass');
      expect(service.getBrokerPassword(), 'pass');
    });

    test('CRUD operations for GroupModel', () {
      final group = GroupModel(
        title: 'Bedroom',
        subtitle: 'Main',
        icon: 'BEDROOM',
      );

      service.createGroup(group: group);
      final groups = service.getGroups();
      expect(groups.length, 1);

      final createdGroup = groups.first;
      expect(createdGroup.title, 'Bedroom');
      expect(createdGroup.id, isNotEmpty);

      final updatedGroup = createdGroup.copyWith(title: 'Master Bedroom');
      service.updateGroup(group: updatedGroup);

      final updatedGroups = service.getGroups();
      expect(updatedGroups.first.title, 'Master Bedroom');

      service.deleteGroup(groupId: updatedGroup.id);
      expect(service.getGroups().isEmpty, isTrue);
    });

    test('CRUD operations for DeviceModel', () {
      final device = DeviceModel(
        title: 'Bed Lamp',
        subtitle: 'Table',
        icon: 'LIGHT',
        tileType: DeviceTileType.boolean,
        groupId: 'grp_01',
      );

      service.createDevice(device: device);
      final devices = service.getDevices();
      expect(devices.length, 1);

      final createdDevice = devices.first;
      expect(createdDevice.title, 'Bed Lamp');
      expect(createdDevice.id, isNotEmpty);

      final updatedDevice = createdDevice.copyWith(title: 'Floor Lamp');
      service.updateDevice(device: updatedDevice);

      final updatedDevices = service.getDevices();
      expect(updatedDevices.first.title, 'Floor Lamp');

      service.deleteDevice(deviceId: updatedDevice.id);
      expect(service.getDevices().isEmpty, isTrue);
    });

    test('fails to create duplicate group name', () {
      final group1 = GroupModel(title: 'Kitchen', subtitle: '', icon: '');
      final group2 = GroupModel(title: 'Kitchen', subtitle: '', icon: '');

      service.createGroup(group: group1);
      expect(
        () => service.createGroup(group: group2),
        throwsA(isA<Exception>()),
      );
    });
  });
}
