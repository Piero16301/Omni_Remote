import 'dart:io';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockPerformanceService extends Mock implements PerformanceService;

class MockTrace extends Mock implements Trace;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tempDirForPathProvider = Directory.systemTemp.createTempSync(
    'path_provider_mock',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return tempDirForPathProvider.path;
          }
          return null;
        },
      );
  late HiveLocalStorageRepository repository;
  late PerformanceService performanceService;
  late Trace trace;
  late Directory tempDir;

  setUpAll(() async {
    registerFallbackValue(StackTrace.current);
  });

  tearDownAll(() {
    if (tempDirForPathProvider.existsSync()) {
      tempDirForPathProvider.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);

    performanceService = MockPerformanceService();
    trace = MockTrace();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<PerformanceService>()) {
      await getIt.unregister<PerformanceService>();
    }
    getIt.registerSingleton<PerformanceService>(performanceService);

    when(() => performanceService.startTrace(any<String>())).thenReturn(trace);
    when(() => trace.stop()).thenAnswer((_) async {});

    repository = HiveLocalStorageRepository();

    await repository.initialize();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }

    try {
      await Hive.deleteFromDisk();
    } on Exception catch (_) {}
  });

  group('HiveLocalStorageRepository', () {
    test('returns null when settings are not saved', () {
      expect(repository.getLanguage(), isNull);
      expect(repository.getTheme(), isNull);
      expect(repository.getBaseColor(), isNull);
      expect(repository.getFontFamily(), isNull);
      expect(repository.getBrokerUrl(), isNull);
      expect(repository.getBrokerPort(), isNull);
      expect(repository.getBrokerUsername(), isNull);
      expect(repository.getBrokerPassword(), isNull);
    });

    test('saveLanguage and getLanguage', () {
      const locale = Locale('es', 'ES');
      repository.saveLanguage(language: locale);
      final result = repository.getLanguage();
      expect(result, equals(locale));
    });

    test('saveTheme and getTheme', () {
      const theme = ThemeMode.dark;
      repository.saveTheme(theme: theme);
      final result = repository.getTheme();
      expect(result, equals(theme));
    });

    test('saveBaseColor and getBaseColor', () {
      const color = Colors.green;
      repository.saveBaseColor(baseColor: color);
      final result = repository.getBaseColor();

      expect(result?.toARGB32(), equals(color.toARGB32()));
    });

    test('saveFontFamily and getFontFamily', () {
      const font = 'Outfit';
      repository.saveFontFamily(fontFamily: font);
      final result = repository.getFontFamily();
      expect(result, equals(font));
    });

    test('Broker credentials methods', () {
      repository.saveBrokerUrl(brokerUrl: 'mqtt.eclipseprojects.io');
      expect(repository.getBrokerUrl(), equals('mqtt.eclipseprojects.io'));

      repository.saveBrokerPort(brokerPort: '1883');
      expect(repository.getBrokerPort(), equals('1883'));

      repository.saveBrokerUsername(brokerUsername: 'user');
      expect(repository.getBrokerUsername(), equals('user'));

      repository.saveBrokerPassword(brokerPassword: 'pass');
      expect(repository.getBrokerPassword(), equals('pass'));
    });

    test('createGroup throws exception if duplicate name', () {
      final group = GroupModel(
        id: '1',
        title: 'Test Group',
        subtitle: 'Subtitle',
        icon: 'icon_name',
      );
      repository.createGroup(group: group);

      expect(
        () => repository.createGroup(group: group),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('DUPLICATE_GROUP_NAME'),
          ),
        ),
      );
    });

    test('updateGroup throws if duplicate name', () {
      repository
        ..createGroup(
          group: GroupModel(
            id: '1',
            title: 'Group-U1',
            subtitle: 'S',
            icon: 'i',
          ),
        )
        ..createGroup(
          group: GroupModel(
            id: '2',
            title: 'Group-U2',
            subtitle: 'S',
            icon: 'i',
          ),
        );
      final groups = repository.getGroups();
      final group1 = groups.firstWhere((g) => g.title == 'Group-U1');

      final updatedGroup = group1.copyWith(title: 'Group-U2');

      expect(
        () => repository.updateGroup(group: updatedGroup),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('DUPLICATE_GROUP_NAME'),
          ),
        ),
      );
    });

    test('deleteGroup throws if not empty', () {
      repository.createGroup(
        group: GroupModel(
          id: 'g1',
          title: 'Group-DE',
          subtitle: 'S',
          icon: 'i',
        ),
      );
      final group = repository.getGroups().firstWhere(
        (g) => g.title == 'Group-DE',
      );

      repository.createDevice(
        device: DeviceModel(
          id: 'd1',
          title: 'D-DE',
          subtitle: 'S',
          groupId: group.id,
          icon: 'i',
          tileType: DeviceTileType.boolean,
        ),
      );

      expect(
        () => repository.deleteGroup(groupId: group.id),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('GROUP_NOT_EMPTY'),
          ),
        ),
      );
    });

    test('createDevice and updateDevice duplicate checking', () {
      repository.createGroup(
        group: GroupModel(
          id: 'g1',
          title: 'Group-Dup',
          subtitle: 'S',
          icon: 'i',
        ),
      );
      final group = repository.getGroups().firstWhere(
        (g) => g.title == 'Group-Dup',
      );

      final device1 = DeviceModel(
        id: 'd1',
        title: 'Device-D1',
        subtitle: 'S',
        groupId: group.id,
        icon: 'i',
        tileType: DeviceTileType.boolean,
      );
      repository.createDevice(device: device1);

      expect(
        () => repository.createDevice(
          device: device1.copyWith(id: 'd2', title: 'Device-D1'),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('DUPLICATE_DEVICE_NAME'),
          ),
        ),
      );

      repository.createDevice(
        device: DeviceModel(
          id: 'd2',
          title: 'Device-D2',
          subtitle: 'S',
          groupId: group.id,
          icon: 'i',
          tileType: DeviceTileType.boolean,
        ),
      );
      final createdDevice2 = repository.getDevices().firstWhere(
        (d) => d.title == 'Device-D2',
      );

      expect(
        () => repository.updateDevice(
          device: createdDevice2.copyWith(title: 'Device-D1'),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('DUPLICATE_DEVICE_NAME'),
          ),
        ),
      );
    });

    test('deleteDevice throws if not found', () {
      expect(
        () => repository.deleteDevice(deviceId: 'unknown'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('DEVICE_NOT_FOUND'),
          ),
        ),
      );
    });

    test('updateGroup updates group successfully', () {
      repository.createGroup(
        group: GroupModel(
          id: '1',
          title: 'Initial Title',
          subtitle: 'Sub',
          icon: 'ic',
        ),
      );
      final createdGroup = repository.getGroups().firstWhere(
        (g) => g.title == 'Initial Title',
      );
      final updated = createdGroup.copyWith(title: 'Updated Title');
      repository.updateGroup(group: updated);
      final found = repository.getGroups().firstWhere(
        (g) => g.id == createdGroup.id,
      );
      expect(found.title, equals('Updated Title'));
    });

    test('deleteGroup deletes empty group and throws if not found', () {
      repository.createGroup(
        group: GroupModel(
          id: 'to-delete',
          title: 'Delete Me Group',
          subtitle: 'Sub',
          icon: 'ic',
        ),
      );
      final group = repository.getGroups().firstWhere(
        (g) => g.title == 'Delete Me Group',
      );
      repository.deleteGroup(groupId: group.id);
      expect(repository.getGroups().any((g) => g.id == group.id), isFalse);

      expect(
        () => repository.deleteGroup(groupId: 'non-existent-group'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('GROUP_NOT_FOUND'),
          ),
        ),
      );
    });

    test(
      'updateDevice and deleteDevice updates and deletes device successfully',
      () {
        repository.createGroup(
          group: GroupModel(
            id: 'g-up',
            title: 'Group Up Dev',
            subtitle: 'S',
            icon: 'i',
          ),
        );
        final group = repository.getGroups().firstWhere(
          (g) => g.title == 'Group Up Dev',
        );
        repository.createDevice(
          device: DeviceModel(
            id: 'd-up',
            title: 'Device Up Dev',
            subtitle: 'S',
            groupId: group.id,
            icon: 'i',
            tileType: DeviceTileType.boolean,
          ),
        );
        final device = repository.getDevices().firstWhere(
          (d) => d.title == 'Device Up Dev',
        );
        final updated = device.copyWith(title: 'Device Updated Dev');
        repository.updateDevice(device: updated);
        final found = repository.getDevices().firstWhere(
          (d) => d.id == device.id,
        );
        expect(found.title, equals('Device Updated Dev'));

        repository.deleteDevice(deviceId: device.id);
        expect(repository.getDevices().any((d) => d.id == device.id), isFalse);
      },
    );

    test('Listenable functionality', () {
      final groupsListenable = repository.getGroupsListenable();
      final devicesListenable = repository.getDevicesListenable();

      void groupListener() {}
      void deviceListener() {}

      groupsListenable.addListener(groupListener);
      devicesListenable.addListener(deviceListener);

      final initialGroups = groupsListenable.value.length;
      repository.createGroup(
        group: GroupModel(
          id: 'g-l',
          title: 'G-Listenable',
          subtitle: 'S',
          icon: 'i',
        ),
      );
      expect(groupsListenable.value.length, equals(initialGroups + 1));

      final initialDevices = devicesListenable.value.length;
      final group = repository.getGroups().firstWhere(
        (g) => g.title == 'G-Listenable',
      );
      repository.createDevice(
        device: DeviceModel(
          id: 'd-l',
          title: 'D-Listenable',
          subtitle: 'S',
          groupId: group.id,
          icon: 'i',
          tileType: DeviceTileType.boolean,
        ),
      );
      expect(devicesListenable.value.length, equals(initialDevices + 1));

      groupsListenable.removeListener(groupListener);
      devicesListenable.removeListener(deviceListener);
    });

    test('MockLocalStorageRepository predefined values and CRUD', () async {
      final mock = MockLocalStorageRepository();
      await mock.initialize();

      expect(mock.getLanguage(), const Locale('en', 'US'));
      expect(mock.getTheme(), ThemeMode.light);
      expect(mock.getBaseColor(), Colors.blue);
      expect(mock.getFontFamily(), isNotEmpty);
      expect(mock.getBrokerUrl(), isNotEmpty);
      expect(mock.getBrokerPort(), isNotEmpty);
      expect(mock.getBrokerUsername(), isNotEmpty);
      expect(mock.getBrokerPassword(), isNotEmpty);

      mock
        ..saveLanguage(language: const Locale('es', 'ES'))
        ..saveTheme(theme: ThemeMode.dark)
        ..saveBaseColor(baseColor: Colors.red)
        ..saveFontFamily(fontFamily: 'Roboto')
        ..saveBrokerUrl(brokerUrl: 'test.broker.io')
        ..saveBrokerPort(brokerPort: '8883')
        ..saveBrokerUsername(brokerUsername: 'user2')
        ..saveBrokerPassword(brokerPassword: 'pass2');

      expect(mock.getLanguage(), const Locale('es', 'ES'));
      expect(mock.getTheme(), ThemeMode.dark);
      expect(mock.getBaseColor(), Colors.red);
      expect(mock.getFontFamily(), 'Roboto');
      expect(mock.getBrokerUrl(), 'test.broker.io');
      expect(mock.getBrokerPort(), '8883');
      expect(mock.getBrokerUsername(), 'user2');
      expect(mock.getBrokerPassword(), 'pass2');

      final initialGroupsCount = mock.getGroups().length;
      final initialDevicesCount = mock.getDevices().length;
      expect(initialGroupsCount, greaterThan(0));
      expect(initialDevicesCount, greaterThan(0));
      expect(mock.getGroupsListenable().value.length, initialGroupsCount);
      expect(mock.getDevicesListenable().value.length, initialDevicesCount);

      mock.createGroup(
        group: GroupModel(title: 'Garage', subtitle: 'Sub', icon: 'GARAGE'),
      );
      expect(mock.getGroups().length, initialGroupsCount + 1);
      final createdGroup = mock.getGroups().last;

      mock.updateGroup(group: createdGroup.copyWith(subtitle: 'Updated Sub'));
      expect(
        mock.getGroups().firstWhere((g) => g.id == createdGroup.id).subtitle,
        'Updated Sub',
      );

      mock.createDevice(
        device: DeviceModel(
          title: 'Garage Door',
          subtitle: 'Main',
          groupId: createdGroup.id,
          icon: 'GARAGE_DOOR',
          tileType: DeviceTileType.boolean,
        ),
      );
      expect(mock.getDevices().length, initialDevicesCount + 1);
      final createdDevice = mock.getDevices().last;

      mock.updateDevice(
        device: createdDevice.copyWith(subtitle: 'Updated Main'),
      );
      expect(
        mock.getDevices().firstWhere((d) => d.id == createdDevice.id).subtitle,
        'Updated Main',
      );

      expect(() => mock.deleteGroup(groupId: createdGroup.id), throwsException);

      mock
        ..deleteDevice(deviceId: createdDevice.id)
        ..deleteGroup(groupId: createdGroup.id);

      expect(mock.getDevices().length, initialDevicesCount);
      expect(mock.getGroups().length, initialGroupsCount);
    });
  });
}
