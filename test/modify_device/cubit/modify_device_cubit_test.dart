import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/modify_device/modify_device.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ModifyDeviceCubit', () {
    late LocalStorageService mockLocalStorageService;
    late ModifyDeviceCubit cubit;

    setUp(() {
      mockLocalStorageService = MockLocalStorageService();
      getIt.registerSingleton<LocalStorageService>(mockLocalStorageService);

      when(() => mockLocalStorageService.getGroups()).thenReturn([
        GroupModel(id: 'grp_123', title: 'Test Group', subtitle: '', icon: ''),
      ]);

      cubit = ModifyDeviceCubit();
    });

    tearDown(() {
      unawaited(cubit.close());
      unawaited(getIt.reset());
    });

    test('initial state properties', () {
      expect(cubit.state.saveStatus, ModifyDeviceStatus.initial);
      expect(cubit.state.title, isEmpty);
      expect(cubit.state.deviceModel, isNull);
    });

    blocTest<ModifyDeviceCubit, ModifyDeviceState>(
      'deviceReceived populates state when device is provided',
      build: () => cubit,
      act: (cubit) => cubit.deviceReceived(
        DeviceModel(
          id: 'dev_1',
          title: 'Light 1',
          subtitle: 'Main',
          icon: 'LIGHT',
          tileType: DeviceTileType.number,
          groupId: 'grp_123',
          rangeMax: 100,
          divisions: 10,
          interval: 10,
        ),
      ),
      expect: () => [
        isA<ModifyDeviceState>()
            .having((s) => s.title, 'title', 'Light 1')
            .having((s) => s.tileType, 'type', DeviceTileType.number)
            .having((s) => s.selectedGroupId, 'groupId', 'grp_123')
            .having((s) => s.deviceModel, 'model', isNotNull),
      ],
    );

    blocTest<ModifyDeviceCubit, ModifyDeviceState>(
      'changeTitle updates title',
      build: () => cubit,
      act: (cubit) => cubit.changeTitle('New Title'),
      expect: () => [
        isA<ModifyDeviceState>().having((s) => s.title, 'title', 'New Title'),
      ],
    );

    blocTest<ModifyDeviceCubit, ModifyDeviceState>(
      'changeTileType updates type',
      build: () => cubit,
      act: (cubit) => cubit.changeTileType(DeviceTileType.number),
      expect: () => [
        isA<ModifyDeviceState>()
            .having((s) => s.tileType, 'type', DeviceTileType.number),
      ],
    );

    blocTest<ModifyDeviceCubit, ModifyDeviceState>(
      'resetSaveStatus sets to initial',
      build: () => cubit,
      seed: () =>
          const ModifyDeviceState(saveStatus: ModifyDeviceStatus.success),
      act: (cubit) => cubit.resetSaveStatus(),
      expect: () => [
        isA<ModifyDeviceState>()
            .having((s) => s.saveStatus, 'status', ModifyDeviceStatus.initial),
      ],
    );
  });
}
