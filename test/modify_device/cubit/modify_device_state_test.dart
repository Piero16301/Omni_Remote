import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/modify_device/modify_device.dart';

void main() {
  group('ModifyDeviceStatus', () {
    test('returns correct flags', () {
      expect(ModifyDeviceStatus.initial.isInitial, isTrue);
      expect(ModifyDeviceStatus.loading.isLoading, isTrue);
      expect(ModifyDeviceStatus.success.isSuccess, isTrue);
      expect(ModifyDeviceStatus.failure.isFailure, isTrue);
    });
  });

  group('ModifyDeviceState', () {
    const formKey = GlobalObjectKey<FormState>('modify_device_form_test');

    test('supports value equality', () {
      expect(
        const ModifyDeviceState(),
        const ModifyDeviceState(),
      );
    });

    test('props are correct', () {
      const state = ModifyDeviceState();
      expect(
        state.props,
        <Object?>[
          '',
          '',
          IconHelper.getDeviceFirstIcon,
          DeviceTileType.boolean,
          0.0,
          0.0,
          0,
          0.0,
          state.formKey,
          null,
          ModifyDeviceStatus.initial,
          ModifyDeviceError.none,
          null,
        ],
      );
    });

    test('copyWith returns object with updated properties', () {
      final mockDevice = DeviceModel(
        id: '1',
        title: 'Light',
        subtitle: 'Room',
        icon: 'LIGHT',
        tileType: DeviceTileType.number,
        groupId: 'g1',
        rangeMin: 10,
        rangeMax: 100,
        divisions: 5,
        interval: 10,
      );

      final state = const ModifyDeviceState().copyWith(
        title: 'New Title',
        subtitle: 'New Subtitle',
        icon: 'NEW_ICON',
        tileType: DeviceTileType.number,
        rangeMin: 10,
        rangeMax: 100,
        divisions: 5,
        interval: 10,
        formKey: formKey,
        deviceModel: mockDevice,
        saveStatus: ModifyDeviceStatus.success,
        modifyDeviceError: ModifyDeviceError.noGroupSelected,
        selectedGroupId: 'g1',
      );

      expect(
        state,
        ModifyDeviceState(
          title: 'New Title',
          subtitle: 'New Subtitle',
          icon: 'NEW_ICON',
          tileType: DeviceTileType.number,
          rangeMin: 10,
          rangeMax: 100,
          divisions: 5,
          interval: 10,
          formKey: formKey,
          deviceModel: mockDevice,
          saveStatus: ModifyDeviceStatus.success,
          modifyDeviceError: ModifyDeviceError.noGroupSelected,
          selectedGroupId: 'g1',
        ),
      );
    });
  });
}
