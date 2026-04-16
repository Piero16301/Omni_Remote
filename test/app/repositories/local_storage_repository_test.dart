import 'dart:io';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockPerformanceService extends Mock implements PerformanceService {}

class MockTrace extends Mock implements Trace {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tempDirForPathProvider =
      Directory.systemTemp.createTempSync('path_provider_mock');

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
      getIt.unregister<PerformanceService>();
    }
    getIt.registerSingleton<PerformanceService>(performanceService);

    when(() => performanceService.startTrace(any<String>())).thenReturn(trace);
    when(() => trace.stop()).thenAnswer((_) async {});

    repository = HiveLocalStorageRepository();

    if (!Hive.isAdapterRegistered(GroupModelAdapter().typeId)) {
      Hive.registerAdapter(GroupModelAdapter());
    }
    if (!Hive.isAdapterRegistered(DeviceModelAdapter().typeId)) {
      Hive.registerAdapter(DeviceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(DeviceTileTypeAdapter().typeId)) {
      Hive.registerAdapter(DeviceTileTypeAdapter());
    }

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
          group:
              GroupModel(id: '1', title: 'Group-U1', subtitle: 'S', icon: 'i'),
        )
        ..createGroup(
          group:
              GroupModel(id: '2', title: 'Group-U2', subtitle: 'S', icon: 'i'),
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
      final group =
          repository.getGroups().firstWhere((g) => g.title == 'Group-DE');

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
      final group =
          repository.getGroups().firstWhere((g) => g.title == 'Group-Dup');

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
      final createdDevice2 =
          repository.getDevices().firstWhere((d) => d.title == 'Device-D2');

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
      final group =
          repository.getGroups().firstWhere((g) => g.title == 'G-Listenable');
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

    test('MockLocalStorageRepository coverage', () async {
      final mock = MockLocalStorageRepository();
      await mock.initialize();
      mock.saveLanguage(language: const Locale('en'));
      expect(mock.getLanguage(), isNotNull);
      mock.saveTheme(theme: ThemeMode.light);
      expect(mock.getTheme(), isNotNull);
      mock.saveBaseColor(baseColor: Colors.red);
      expect(mock.getBaseColor(), isNotNull);
      mock.saveFontFamily(fontFamily: 'f');
      expect(mock.getFontFamily(), isNotNull);
      mock.saveBrokerUrl(brokerUrl: 'u');
      expect(mock.getBrokerUrl(), isEmpty);
      mock.saveBrokerPort(brokerPort: 'p');
      expect(mock.getBrokerPort(), isEmpty);
      mock.saveBrokerUsername(brokerUsername: 'u');
      expect(mock.getBrokerUsername(), isEmpty);
      mock.saveBrokerPassword(brokerPassword: 'p');
      expect(mock.getBrokerPassword(), isEmpty);
      mock.createGroup(
        group: GroupModel(id: '1', title: 'G', subtitle: 'S', icon: 'i'),
      );
      expect(mock.getGroups(), isEmpty);
      expect(mock.getGroupsListenable().value, isEmpty);
      mock
        ..updateGroup(
          group: GroupModel(id: '1', title: 'G', subtitle: 'S', icon: 'i'),
        )
        ..deleteGroup(groupId: '1')
        ..createDevice(
          device: DeviceModel(
            id: '1',
            title: 'D',
            subtitle: 'S',
            groupId: '1',
            icon: 'i',
            tileType: DeviceTileType.boolean,
          ),
        );
      expect(mock.getDevices(), isEmpty);
      expect(mock.getDevicesListenable().value, isEmpty);
      mock
        ..updateDevice(
          device: DeviceModel(
            id: '1',
            title: 'D',
            subtitle: 'S',
            groupId: '1',
            icon: 'i',
            tileType: DeviceTileType.boolean,
          ),
        )
        ..deleteDevice(deviceId: '1');
    });
  });
}
