import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

void main() {
  late LocalStorageRepository repository;
  late LocalStorageService service;

  setUp(() {
    repository = MockLocalStorageRepository();
    service = LocalStorageService(localStorageRepository: repository);
  });

  group('LocalStorageService', () {
    test('initialize calls repository.initialize', () async {
      when(() => repository.initialize()).thenAnswer((_) async {});
      await service.initialize();
      verify(() => repository.initialize()).called(1);
    });

    test('saveLanguage calls repository.saveLanguage', () {
      const locale = Locale('en', 'US');
      service.saveLanguage(language: locale);
      verify(() => repository.saveLanguage(language: locale)).called(1);
    });

    test('getLanguage calls repository.getLanguage', () {
      const locale = Locale('en', 'US');
      when(() => repository.getLanguage()).thenReturn(locale);
      final result = service.getLanguage();
      expect(result, equals(locale));
      verify(() => repository.getLanguage()).called(1);
    });

    test('saveTheme calls repository.saveTheme', () {
      const theme = ThemeMode.dark;
      service.saveTheme(theme: theme);
      verify(() => repository.saveTheme(theme: theme)).called(1);
    });

    test('getTheme calls repository.getTheme', () {
      const theme = ThemeMode.dark;
      when(() => repository.getTheme()).thenReturn(theme);
      final result = service.getTheme();
      expect(result, equals(theme));
      verify(() => repository.getTheme()).called(1);
    });

    test('saveBaseColor calls repository.saveBaseColor', () {
      const color = Colors.red;
      service.saveBaseColor(baseColor: color);
      verify(() => repository.saveBaseColor(baseColor: color)).called(1);
    });

    test('getBaseColor calls repository.getBaseColor', () {
      const color = Colors.red;
      when(() => repository.getBaseColor()).thenReturn(color);
      final result = service.getBaseColor();
      expect(result, equals(color));
      verify(() => repository.getBaseColor()).called(1);
    });

    test('saveFontFamily calls repository.saveFontFamily', () {
      const fontFamily = 'Roboto';
      service.saveFontFamily(fontFamily: fontFamily);
      verify(() => repository.saveFontFamily(fontFamily: fontFamily)).called(1);
    });

    test('getFontFamily calls repository.getFontFamily', () {
      const fontFamily = 'Roboto';
      when(() => repository.getFontFamily()).thenReturn(fontFamily);
      final result = service.getFontFamily();
      expect(result, equals(fontFamily));
      verify(() => repository.getFontFamily()).called(1);
    });

    test('saveBrokerUrl calls repository.saveBrokerUrl', () {
      const url = 'localhost';
      service.saveBrokerUrl(brokerUrl: url);
      verify(() => repository.saveBrokerUrl(brokerUrl: url)).called(1);
    });

    test('getBrokerUrl calls repository.getBrokerUrl', () {
      const url = 'localhost';
      when(() => repository.getBrokerUrl()).thenReturn(url);
      final result = service.getBrokerUrl();
      expect(result, equals(url));
      verify(() => repository.getBrokerUrl()).called(1);
    });

    test('saveBrokerPort calls repository.saveBrokerPort', () {
      const port = '1883';
      service.saveBrokerPort(brokerPort: port);
      verify(() => repository.saveBrokerPort(brokerPort: port)).called(1);
    });

    test('getBrokerPort calls repository.getBrokerPort', () {
      const port = '1883';
      when(() => repository.getBrokerPort()).thenReturn(port);
      final result = service.getBrokerPort();
      expect(result, equals(port));
      verify(() => repository.getBrokerPort()).called(1);
    });

    test('saveBrokerUsername calls repository.saveBrokerUsername', () {
      const username = 'user';
      service.saveBrokerUsername(brokerUsername: username);
      verify(() => repository.saveBrokerUsername(brokerUsername: username))
          .called(1);
    });

    test('getBrokerUsername calls repository.getBrokerUsername', () {
      const username = 'user';
      when(() => repository.getBrokerUsername()).thenReturn(username);
      final result = service.getBrokerUsername();
      expect(result, equals(username));
      verify(() => repository.getBrokerUsername()).called(1);
    });

    test('saveBrokerPassword calls repository.saveBrokerPassword', () {
      const password = 'pass';
      service.saveBrokerPassword(brokerPassword: password);
      verify(() => repository.saveBrokerPassword(brokerPassword: password))
          .called(1);
    });

    test('getBrokerPassword calls repository.getBrokerPassword', () {
      const password = 'pass';
      when(() => repository.getBrokerPassword()).thenReturn(password);
      final result = service.getBrokerPassword();
      expect(result, equals(password));
      verify(() => repository.getBrokerPassword()).called(1);
    });

    test('getGroupsListenable calls repository.getGroupsListenable', () {
      final listenable = ValueNotifier<List<GroupModel>>([]);
      when(() => repository.getGroupsListenable()).thenReturn(listenable);
      final result = service.getGroupsListenable();
      expect(result, equals(listenable));
      verify(() => repository.getGroupsListenable()).called(1);
    });

    test('createGroup calls repository.createGroup', () {
      final group = GroupModel(
        id: '1',
        title: 'Group 1',
        subtitle: 'Subtitle 1',
        icon: 'icon_name',
      );
      service.createGroup(group: group);
      verify(() => repository.createGroup(group: group)).called(1);
    });

    test('getGroups calls repository.getGroups', () {
      final groups = [
        GroupModel(
          id: '1',
          title: 'Group 1',
          subtitle: 'Subtitle 1',
          icon: 'icon_name',
        ),
      ];
      when(() => repository.getGroups()).thenReturn(groups);
      final result = service.getGroups();
      expect(result, equals(groups));
      verify(() => repository.getGroups()).called(1);
    });

    test('updateGroup calls repository.updateGroup', () {
      final group = GroupModel(
        id: '1',
        title: 'Group 1',
        subtitle: 'Subtitle 1',
        icon: 'icon_name',
      );
      service.updateGroup(group: group);
      verify(() => repository.updateGroup(group: group)).called(1);
    });

    test('deleteGroup calls repository.deleteGroup', () {
      const groupId = '1';
      service.deleteGroup(groupId: groupId);
      verify(() => repository.deleteGroup(groupId: groupId)).called(1);
    });

    test('getDevicesListenable calls repository.getDevicesListenable', () {
      final listenable = ValueNotifier<List<DeviceModel>>([]);
      when(() => repository.getDevicesListenable()).thenReturn(listenable);
      final result = service.getDevicesListenable();
      expect(result, equals(listenable));
      verify(() => repository.getDevicesListenable()).called(1);
    });

    test('createDevice calls repository.createDevice', () {
      final device = DeviceModel(
        id: '1',
        title: 'Device 1',
        subtitle: 'Subtitle 1',
        groupId: 'g1',
        icon: 'icon_name',
        tileType: DeviceTileType.boolean,
      );
      service.createDevice(device: device);
      verify(() => repository.createDevice(device: device)).called(1);
    });

    test('getDevices calls repository.getDevices', () {
      final devices = [
        DeviceModel(
          id: '1',
          title: 'Device 1',
          subtitle: 'Subtitle 1',
          groupId: 'g1',
          icon: 'icon_name',
          tileType: DeviceTileType.boolean,
        ),
      ];
      when(() => repository.getDevices()).thenReturn(devices);
      final result = service.getDevices();
      expect(result, equals(devices));
      verify(() => repository.getDevices()).called(1);
    });

    test('updateDevice calls repository.updateDevice', () {
      final device = DeviceModel(
        id: '1',
        title: 'Device 1',
        subtitle: 'Subtitle 1',
        groupId: 'g1',
        icon: 'icon_name',
        tileType: DeviceTileType.boolean,
      );
      service.updateDevice(device: device);
      verify(() => repository.updateDevice(device: device)).called(1);
    });

    test('deleteDevice calls repository.deleteDevice', () {
      const deviceId = '1';
      service.deleteDevice(deviceId: deviceId);
      verify(() => repository.deleteDevice(deviceId: deviceId)).called(1);
    });
  });
}
