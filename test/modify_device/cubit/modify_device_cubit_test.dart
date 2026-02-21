import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/modify_device/modify_device.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

class FakeDeviceModel extends Fake implements DeviceModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDeviceModel());
  });

  group('ModifyDeviceCubit', () {
    late LocalStorageService mockLocalStorageService;

    final testGroups = [
      GroupModel(id: 'g1', title: 'Group 1', subtitle: '', icon: ''),
    ];

    setUp(() async {
      mockLocalStorageService = MockLocalStorageService();
      if (!getIt.isRegistered<LocalStorageService>()) {
        getIt.registerSingleton<LocalStorageService>(mockLocalStorageService);
      } else {
        await getIt.unregister<LocalStorageService>();
        getIt.registerSingleton<LocalStorageService>(mockLocalStorageService);
      }

      when(() => mockLocalStorageService.getGroups()).thenReturn(testGroups);
    });

    tearDown(getIt.reset);

    test('initial state is correct', () {
      final cubit = ModifyDeviceCubit();
      expect(cubit.state, const ModifyDeviceState());
      unawaited(cubit.close());
    });

    blocTest<ModifyDeviceCubit, ModifyDeviceState>(
      'deviceReceived updates state correctly when device is null',
      build: ModifyDeviceCubit.new,
      act: (cubit) => cubit.deviceReceived(null),
      expect: () => [
        isA<ModifyDeviceState>()
            .having((s) => s.selectedGroupId, 'selectedGroupId', 'g1'),
      ],
    );

    blocTest<ModifyDeviceCubit, ModifyDeviceState>(
      'deviceReceived updates state correctly with device',
      build: ModifyDeviceCubit.new,
      act: (cubit) => cubit.deviceReceived(
        DeviceModel(
          id: 'd1',
          title: 'Device',
          subtitle: 'Sub',
          icon: 'icon1',
          tileType: DeviceTileType.number,
          groupId: 'g1',
          rangeMin: 10,
          rangeMax: 20,
          divisions: 5,
          interval: 2,
        ),
      ),
      expect: () => [
        isA<ModifyDeviceState>()
            .having((s) => s.title, 'title', 'Device')
            .having((s) => s.subtitle, 'subtitle', 'Sub')
            .having((s) => s.icon, 'icon', 'icon1')
            .having((s) => s.tileType, 'tileType', DeviceTileType.number)
            .having((s) => s.rangeMin, 'rangeMin', 10.0)
            .having((s) => s.rangeMax, 'rangeMax', 20.0)
            .having((s) => s.divisions, 'divisions', 5)
            .having((s) => s.interval, 'interval', 2.0)
            .having((s) => s.selectedGroupId, 'selectedGroupId', 'g1')
            .having((s) => s.deviceModel?.id, 'deviceModel', 'd1'),
      ],
    );

    blocTest<ModifyDeviceCubit, ModifyDeviceState>(
      'change properties updates state correctly',
      build: ModifyDeviceCubit.new,
      act: (cubit) {
        cubit
          ..changeTitle('New Title')
          ..changeSubtitle('New Sub')
          ..changeIcon('New Icon')
          ..changeTileType(DeviceTileType.number)
          ..changeRangeMin(1)
          ..changeRangeMax(100)
          ..changeDivisions(10)
          ..changeInterval(2)
          ..changeSelectedGroup('g2');
      },
      expect: () => [
        isA<ModifyDeviceState>().having((s) => s.title, 'title', 'New Title'),
        isA<ModifyDeviceState>()
            .having((s) => s.subtitle, 'subtitle', 'New Sub'),
        isA<ModifyDeviceState>().having((s) => s.icon, 'icon', 'New Icon'),
        isA<ModifyDeviceState>()
            .having((s) => s.tileType, 'tileType', DeviceTileType.number),
        isA<ModifyDeviceState>().having((s) => s.rangeMin, 'rangeMin', 1.0),
        isA<ModifyDeviceState>().having((s) => s.rangeMax, 'rangeMax', 100.0),
        isA<ModifyDeviceState>().having((s) => s.divisions, 'divisions', 10),
        isA<ModifyDeviceState>().having((s) => s.interval, 'interval', 2.0),
        isA<ModifyDeviceState>()
            .having((s) => s.selectedGroupId, 'selectedGroupId', 'g2'),
      ],
    );

    testWidgets('saveDeviceModel fails validation', (tester) async {
      final cubit = ModifyDeviceCubit();
      when(() => mockLocalStorageService.getGroups()).thenReturn(testGroups);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: cubit.state.formKey,
              child: TextFormField(
                validator: (_) => 'Error',
              ),
            ),
          ),
        ),
      );
      cubit.saveDeviceModel();

      expect(cubit.state.saveStatus, ModifyDeviceStatus.initial);
      unawaited(cubit.close());
    });

    testWidgets('saveDeviceModel creates new device', (tester) async {
      final cubit = ModifyDeviceCubit();
      when(() => mockLocalStorageService.getGroups()).thenReturn(testGroups);
      when(
        () => mockLocalStorageService.createDevice(
          device: any(named: 'device'),
        ),
      ).thenAnswer((_) async {});

      cubit.deviceReceived(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: cubit.state.formKey,
              child: TextFormField(
                initialValue: 'Valid',
                validator: (_) => null,
              ),
            ),
          ),
        ),
      );

      cubit.saveDeviceModel();

      expect(cubit.state.saveStatus, ModifyDeviceStatus.success);
      verify(
        () => mockLocalStorageService.createDevice(
          device: any(named: 'device'),
        ),
      ).called(1);
      unawaited(cubit.close());
    });

    testWidgets('saveDeviceModel fails when no group is selected',
        (tester) async {
      final cubit = ModifyDeviceCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: cubit.state.formKey,
              child: TextFormField(
                initialValue: 'Valid',
                validator: (_) => null,
              ),
            ),
          ),
        ),
      );

      cubit.saveDeviceModel();

      expect(cubit.state.saveStatus, ModifyDeviceStatus.failure);
      expect(cubit.state.modifyDeviceError, ModifyDeviceError.noGroupSelected);
      unawaited(cubit.close());
    });

    testWidgets('saveDeviceModel updates existing device', (tester) async {
      final cubit = ModifyDeviceCubit();
      when(() => mockLocalStorageService.getGroups()).thenReturn(testGroups);
      when(
        () => mockLocalStorageService.updateDevice(
          device: any(named: 'device'),
        ),
      ).thenAnswer((_) async {});

      cubit.deviceReceived(
        DeviceModel(
          id: 'd1',
          title: 'T',
          subtitle: '',
          icon: '',
          tileType: DeviceTileType.boolean,
          groupId: 'g1',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: cubit.state.formKey,
              child: TextFormField(
                initialValue: 'Valid',
                validator: (_) => null,
              ),
            ),
          ),
        ),
      );

      cubit.saveDeviceModel();

      expect(cubit.state.saveStatus, ModifyDeviceStatus.success);
      verify(
        () => mockLocalStorageService.updateDevice(
          device: any(named: 'device'),
        ),
      ).called(1);
      unawaited(cubit.close());
    });

    testWidgets('saveDeviceModel handles duplicate name error', (tester) async {
      final cubit = ModifyDeviceCubit();
      when(() => mockLocalStorageService.getGroups()).thenReturn(testGroups);
      when(
        () => mockLocalStorageService.createDevice(
          device: any(named: 'device'),
        ),
      ).thenThrow(Exception('DUPLICATE_DEVICE_NAME'));

      cubit.deviceReceived(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: cubit.state.formKey,
              child: TextFormField(
                initialValue: 'Valid',
                validator: (_) => null,
              ),
            ),
          ),
        ),
      );

      cubit.saveDeviceModel();

      expect(cubit.state.saveStatus, ModifyDeviceStatus.failure);
      expect(
        cubit.state.modifyDeviceError,
        ModifyDeviceError.duplicateDeviceName,
      );
      unawaited(cubit.close());
    });

    testWidgets('saveDeviceModel handles unknown error', (tester) async {
      final cubit = ModifyDeviceCubit();
      when(() => mockLocalStorageService.getGroups()).thenReturn(testGroups);
      when(
        () => mockLocalStorageService.createDevice(
          device: any(named: 'device'),
        ),
      ).thenThrow(Exception('UNKNOWN_ERROR'));

      cubit.deviceReceived(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: cubit.state.formKey,
              child: TextFormField(
                initialValue: 'Valid',
                validator: (_) => null,
              ),
            ),
          ),
        ),
      );

      cubit.saveDeviceModel();

      expect(cubit.state.saveStatus, ModifyDeviceStatus.failure);
      expect(cubit.state.modifyDeviceError, ModifyDeviceError.unknown);
      unawaited(cubit.close());
    });
  });
}
