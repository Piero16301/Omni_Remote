import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/home/home.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('HomeCubit', () {
    late LocalStorageService mockLocalStorageService;
    late HomeCubit cubit;

    setUp(() {
      mockLocalStorageService = MockLocalStorageService();
      getIt.registerSingleton<LocalStorageService>(mockLocalStorageService);

      cubit = HomeCubit();
    });

    tearDown(() {
      unawaited(cubit.close());
      unawaited(getIt.reset());
    });

    test('initial state is correct', () {
      expect(cubit.state, const HomeState());
    });

    blocTest<HomeCubit, HomeState>(
      'resetDeleteGroupStatus emits initial status',
      build: () => cubit,
      seed: () => const HomeState(deleteGroupStatus: HomeStatus.success),
      act: (cubit) => cubit.resetDeleteGroupStatus(),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.deleteGroupStatus, 'status', HomeStatus.initial),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'resetDeleteDeviceStatus emits initial status',
      build: () => cubit,
      seed: () => const HomeState(deleteDeviceStatus: HomeStatus.failure),
      act: (cubit) => cubit.resetDeleteDeviceStatus(),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.deleteDeviceStatus, 'status', HomeStatus.initial),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'deleteGroup success emits loading then success',
      build: () {
        when(() => mockLocalStorageService.deleteGroup(groupId: 'grp_01'))
            .thenReturn(null);
        return cubit;
      },
      act: (cubit) => cubit.deleteGroup(
        GroupModel(id: 'grp_01', title: '', subtitle: '', icon: ''),
      ),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.deleteGroupStatus, 'loading', HomeStatus.loading),
        isA<HomeState>()
            .having((s) => s.deleteGroupStatus, 'success', HomeStatus.success),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'deleteGroup fails when group not empty',
      build: () {
        when(() => mockLocalStorageService.deleteGroup(groupId: 'grp_01'))
            .thenThrow(Exception('GROUP_NOT_EMPTY'));
        return cubit;
      },
      act: (cubit) => cubit.deleteGroup(
        GroupModel(id: 'grp_01', title: '', subtitle: '', icon: ''),
      ),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.deleteGroupStatus, 'loading', HomeStatus.loading),
        isA<HomeState>()
            .having((s) => s.deleteGroupStatus, 'failure', HomeStatus.failure)
            .having(
              (s) => s.groupDeleteError,
              'error',
              GroupDeleteError.groupNotEmpty,
            ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'deleteDevice success emits loading then success',
      build: () {
        when(() => mockLocalStorageService.deleteDevice(deviceId: 'dev_01'))
            .thenReturn(null);
        return cubit;
      },
      act: (cubit) => cubit.deleteDevice(
        DeviceModel(
          id: 'dev_01',
          title: '',
          subtitle: '',
          icon: '',
          tileType: DeviceTileType.boolean,
          groupId: '',
        ),
      ),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.deleteDeviceStatus, 'loading', HomeStatus.loading),
        isA<HomeState>()
            .having((s) => s.deleteDeviceStatus, 'success', HomeStatus.success),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'deleteDevice fails when not found emissions',
      build: () {
        when(() => mockLocalStorageService.deleteDevice(deviceId: 'dev_01'))
            .thenThrow(Exception('DEVICE_NOT_FOUND'));
        return cubit;
      },
      act: (cubit) => cubit.deleteDevice(
        DeviceModel(
          id: 'dev_01',
          title: '',
          subtitle: '',
          icon: '',
          tileType: DeviceTileType.number,
          groupId: '',
        ),
      ),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.deleteDeviceStatus, 'loading', HomeStatus.loading),
        isA<HomeState>()
            .having((s) => s.deleteDeviceStatus, 'failure', HomeStatus.failure)
            .having(
              (s) => s.deviceDeleteError,
              'error',
              DeviceDeleteError.deviceNotFound,
            ),
      ],
    );
  });
}
