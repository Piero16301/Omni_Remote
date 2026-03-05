import 'dart:io';

import 'package:flutter/foundation.dart';
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

    tearDown(() async {
      await Hive.box<String>(LocalStorageService.kSettingsBoxName).clear();
      await Hive.box<GroupModel>(LocalStorageService.kGroupsBoxName).clear();
      await Hive.box<DeviceModel>(LocalStorageService.kDevicesBoxName).clear();
      await Hive.box<String>(LocalStorageService.kBrokerBoxName).clear();
    });

    tearDownAll(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('settings return null by default', () {
      expect(service.getLanguage(), isNull);
      expect(service.getTheme(), isNull);
      expect(service.getBaseColor(), isNull);
      expect(service.getFontFamily(), isNull);
      expect(service.getBrokerUrl(), isNull);
      expect(service.getBrokerPort(), isNull);
      expect(service.getBrokerUsername(), isNull);
      expect(service.getBrokerPassword(), isNull);
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

    test('saves and gets baseColor', () {
      service.saveBaseColor(baseColor: Colors.blue);
      expect(service.getBaseColor(), Colors.blue);
    });

    test('saves and gets fontFamily', () {
      service.saveFontFamily(fontFamily: 'Roboto');
      expect(service.getFontFamily(), 'Roboto');
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

    test('throws GROUP_NOT_FOUND when deleting inexistent group', () {
      expect(
        () => service.deleteGroup(groupId: 'not-found'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('GROUP_NOT_FOUND'),
          ),
        ),
      );
    });

    test('throws DUPLICATE_GROUP_NAME when creating same title group', () {
      final group1 = GroupModel(title: 'Kitchen', subtitle: '', icon: '');
      final group2 = GroupModel(title: 'Kitchen', subtitle: '', icon: '');

      service.createGroup(group: group1);
      expect(
        () => service.createGroup(group: group2),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('DUPLICATE_GROUP_NAME'),
          ),
        ),
      );
    });

    test(
        'throws DUPLICATE_GROUP_NAME when updating group to same title '
        'as existing', () {
      service
        ..createGroup(
          group: GroupModel(title: 'Group 1', subtitle: '', icon: ''),
        )
        ..createGroup(
          group: GroupModel(title: 'Group 2', subtitle: '', icon: ''),
        );

      final groups = service.getGroups();
      final group2 = groups.firstWhere((g) => g.title == 'Group 2');

      final updatedGroup2 = group2.copyWith(title: 'Group 1');

      expect(
        () => service.updateGroup(group: updatedGroup2),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('DUPLICATE_GROUP_NAME'),
          ),
        ),
      );
    });

    test('updateGroup does nothing if id not found', () {
      final group = GroupModel(
        id: 'non-existent',
        title: 'Group',
        subtitle: '',
        icon: '',
      );
      service.updateGroup(group: group);
      expect(service.getGroups().isEmpty, isTrue);
    });

    test('throws GROUP_NOT_EMPTY when deleting a group with devices', () {
      service.createGroup(
        group: GroupModel(title: 'Living', subtitle: '', icon: ''),
      );
      final group = service.getGroups().first;

      service.createDevice(
        device: DeviceModel(
          title: 'Light 1',
          subtitle: '',
          icon: '',
          tileType: DeviceTileType.boolean,
          groupId: group.id,
        ),
      );

      expect(
        () => service.deleteGroup(groupId: group.id),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('GROUP_NOT_EMPTY'),
          ),
        ),
      );
    });

    test('getGroupsListenable returns ValueListenable', () async {
      final listenable = service.getGroupsListenable();
      expect(listenable, isA<ValueListenable<List<GroupModel>>>());

      var callbackCalled = 0;
      void listener() {
        callbackCalled++;
      }

      listenable.addListener(listener);
      service.createGroup(
        group: GroupModel(title: 'Test', subtitle: '', icon: ''),
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(callbackCalled, greaterThanOrEqualTo(1));

      final oldCallbackCalled = callbackCalled;
      listenable.removeListener(listener);
      service.createGroup(
        group: GroupModel(title: 'Test 2', subtitle: '', icon: ''),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(callbackCalled, oldCallbackCalled);

      expect(listenable.value.length, 2);
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

    test('throws DEVICE_NOT_FOUND when deleting inexistent device', () {
      expect(
        () => service.deleteDevice(deviceId: 'not-found'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('DEVICE_NOT_FOUND'),
          ),
        ),
      );
    });

    test(
        'throws DUPLICATE_DEVICE_NAME when creating same title device in '
        'same group', () {
      final device1 = DeviceModel(
        title: 'Light 1',
        subtitle: '',
        icon: '',
        tileType: DeviceTileType.boolean,
        groupId: 'g1',
      );
      final device2 = DeviceModel(
        title: 'Light 1',
        subtitle: '',
        icon: '',
        tileType: DeviceTileType.boolean,
        groupId: 'g1',
      );

      service.createDevice(device: device1);
      expect(
        () => service.createDevice(device: device2),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('DUPLICATE_DEVICE_NAME'),
          ),
        ),
      );
    });

    test(
        'throws DUPLICATE_DEVICE_NAME when updating device to same title '
        'as existing', () {
      final device1 = DeviceModel(
        title: 'Light 1',
        subtitle: '',
        icon: '',
        tileType: DeviceTileType.boolean,
        groupId: 'g1',
      );
      final device2 = DeviceModel(
        title: 'Light 2',
        subtitle: '',
        icon: '',
        tileType: DeviceTileType.boolean,
        groupId: 'g1',
      );

      service
        ..createDevice(device: device1)
        ..createDevice(device: device2);

      final devices = service.getDevices();
      final createdDevice2 = devices.firstWhere((d) => d.title == 'Light 2');

      final updatedDevice2 = createdDevice2.copyWith(title: 'Light 1');

      expect(
        () => service.updateDevice(device: updatedDevice2),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('DUPLICATE_DEVICE_NAME'),
          ),
        ),
      );
    });

    test('updateDevice does nothing if id not found', () {
      final device = DeviceModel(
        id: 'non-existent',
        title: 'Device',
        subtitle: '',
        icon: '',
        tileType: DeviceTileType.boolean,
        groupId: '',
      );
      service.updateDevice(device: device);
      expect(service.getDevices().isEmpty, isTrue);
    });

    test('getDevicesListenable returns ValueListenable', () async {
      final listenable = service.getDevicesListenable();
      expect(listenable, isA<ValueListenable<List<DeviceModel>>>());

      var callbackCalled = 0;
      void listener() {
        callbackCalled++;
      }

      listenable.addListener(listener);
      service.createDevice(
        device: DeviceModel(
          title: 'Device 1',
          subtitle: '',
          icon: '',
          tileType: DeviceTileType.boolean,
          groupId: '',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(callbackCalled, greaterThanOrEqualTo(1));

      final oldCallbackCalled = callbackCalled;
      listenable.removeListener(listener);
      service.createDevice(
        device: DeviceModel(
          title: 'Device 2',
          subtitle: '',
          icon: '',
          tileType: DeviceTileType.boolean,
          groupId: '',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(callbackCalled, oldCallbackCalled);

      expect(listenable.value.length, 2);
    });
  });
}
