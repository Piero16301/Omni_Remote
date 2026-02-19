import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/home/home.dart';

void main() {
  group('HomeStatus', () {
    test('returns correct flags', () {
      expect(HomeStatus.initial.isInitial, isTrue);
      expect(HomeStatus.loading.isLoading, isTrue);
      expect(HomeStatus.success.isSuccess, isTrue);
      expect(HomeStatus.failure.isFailure, isTrue);
    });
  });

  group('HomeState', () {
    test('supports value equality', () {
      expect(
        const HomeState(),
        const HomeState(),
      );
    });

    test('props are correct', () {
      expect(
        const HomeState().props,
        <Object?>[
          HomeStatus.initial,
          HomeStatus.initial,
          GroupDeleteError.none,
          DeviceDeleteError.none,
        ],
      );
    });

    test('copyWith returns object with updated properties', () {
      expect(
        const HomeState().copyWith(
          deleteGroupStatus: HomeStatus.success,
          deleteDeviceStatus: HomeStatus.failure,
          groupDeleteError: GroupDeleteError.groupNotEmpty,
          deviceDeleteError: DeviceDeleteError.deviceNotFound,
        ),
        const HomeState(
          deleteGroupStatus: HomeStatus.success,
          deleteDeviceStatus: HomeStatus.failure,
          groupDeleteError: GroupDeleteError.groupNotEmpty,
          deviceDeleteError: DeviceDeleteError.deviceNotFound,
        ),
      );
    });
  });
}
