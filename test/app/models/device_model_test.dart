import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/app/models/device_model.dart';

void main() {
  group('DeviceModel', () {
    test(
        'supports value equality (by properties since no equatable, we test '
        'instantiating)', () {
      final device = DeviceModel(
        title: 'Light 1',
        subtitle: 'Living Room',
        icon: '0xe123',
        tileType: DeviceTileType.boolean,
        groupId: 'grp1',
      );

      expect(device.title, 'Light 1');
      expect(device.subtitle, 'Living Room');
      expect(device.icon, '0xe123');
      expect(device.tileType, DeviceTileType.boolean);
      expect(device.groupId, 'grp1');
      expect(device.id, '');
      expect(device.rangeMin, 0);
      expect(device.rangeMax, 0);
      expect(device.divisions, 0);
      expect(device.interval, 0);
    });

    test('copyWith creates a new instance with updated values', () {
      final device = DeviceModel(
        title: 'Light 1',
        subtitle: 'Living Room',
        icon: '0xe123',
        tileType: DeviceTileType.boolean,
        groupId: 'grp1',
      );

      final updatedDevice = device.copyWith(
        id: 'new_id',
        title: 'Light 2',
        subtitle: 'Bedroom',
        icon: '0xe124',
        tileType: DeviceTileType.number,
        groupId: 'grp2',
        rangeMin: 10,
        rangeMax: 100,
        divisions: 5,
        interval: 10,
      );

      expect(updatedDevice.id, 'new_id');
      expect(updatedDevice.title, 'Light 2');
      expect(updatedDevice.subtitle, 'Bedroom');
      expect(updatedDevice.icon, '0xe124');
      expect(updatedDevice.tileType, DeviceTileType.number);
      expect(updatedDevice.groupId, 'grp2');
      expect(updatedDevice.rangeMin, 10);
      expect(updatedDevice.rangeMax, 100);
      expect(updatedDevice.divisions, 5);
      expect(updatedDevice.interval, 10);
    });
  });
}
