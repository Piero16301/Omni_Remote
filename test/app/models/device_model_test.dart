// ignore_for_file: prefer_int_literals // For Hive typeId

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
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

    test('copyWith with no arguments returns a copy with the same values', () {
      final device = DeviceModel(
        title: 'Light 1',
        subtitle: 'Living Room',
        icon: '0xe123',
        tileType: DeviceTileType.boolean,
        groupId: 'grp1',
      );

      final updatedDevice = device.copyWith();

      expect(updatedDevice.id, device.id);
      expect(updatedDevice.title, device.title);
      expect(updatedDevice.subtitle, device.subtitle);
      expect(updatedDevice.icon, device.icon);
      expect(updatedDevice.tileType, device.tileType);
      expect(updatedDevice.groupId, device.groupId);
      expect(updatedDevice.rangeMin, device.rangeMin);
      expect(updatedDevice.rangeMax, device.rangeMax);
      expect(updatedDevice.divisions, device.divisions);
      expect(updatedDevice.interval, device.interval);
    });
  });

  group('DeviceModelAdapter', () {
    late DeviceModelAdapter adapter;
    late MockBinaryReader reader;
    late MockBinaryWriter writer;

    setUp(() {
      adapter = DeviceModelAdapter();
      reader = MockBinaryReader();
      writer = MockBinaryWriter();
    });

    test('typeId is 1', () {
      expect(adapter.typeId, 1);
    });

    test('read returns valid DeviceModel with non-null fields', () {
      var byteCount = 0;
      when(() => reader.readByte()).thenAnswer((_) {
        if (byteCount == 0) {
          byteCount++;
          return 10;
        }
        final key = byteCount - 1;
        byteCount++;
        return key;
      });

      var readCount = 0;
      when(() => reader.read()).thenAnswer((_) {
        final values = [
          'id1',
          'title1',
          'sub1',
          'icon1',
          DeviceTileType.number,
          'grp1',
          1.0,
          2.0,
          3,
          4.0,
        ];
        final val = values[readCount];
        readCount++;
        return val;
      });

      final result = adapter.read(reader);
      expect(result.id, 'id1');
      expect(result.title, 'title1');
      expect(result.subtitle, 'sub1');
      expect(result.icon, 'icon1');
      expect(result.tileType, DeviceTileType.number);
      expect(result.groupId, 'grp1');
      expect(result.rangeMin, 1.0);
      expect(result.rangeMax, 2.0);
      expect(result.divisions, 3);
      expect(result.interval, 4.0);
    });

    test('read returns valid DeviceModel with null fields', () {
      var byteCount = 0;
      when(() => reader.readByte()).thenAnswer((_) {
        if (byteCount == 0) {
          byteCount++;
          return 10;
        }
        final key = byteCount - 1;
        byteCount++;
        return key;
      });

      when(() => reader.read()).thenReturn(null);

      final result = adapter.read(reader);
      expect(result.id, '');
      expect(result.title, '');
      expect(result.subtitle, '');
      expect(result.icon, '');
      expect(result.tileType, DeviceTileType.boolean);
      expect(result.groupId, '');
      expect(result.rangeMin, 0.0);
      expect(result.rangeMax, 0.0);
      expect(result.divisions, 0);
      expect(result.interval, 0.0);
    });

    test('write assigns correct values', () {
      final device = DeviceModel(
        title: 't',
        subtitle: 's',
        icon: 'i',
        tileType: DeviceTileType.boolean,
        groupId: 'g',
        id: 'id1',
        rangeMin: 1,
        rangeMax: 2,
        divisions: 3,
        interval: 4,
      );

      adapter.write(writer, device);

      verify(() => writer.writeByte(10)).called(1);
      verify(() => writer.writeByte(0)).called(1);
      verify(() => writer.write('id1')).called(1);
      verify(() => writer.writeByte(1)).called(1);
      verify(() => writer.write('t')).called(1);
      verify(() => writer.writeByte(2)).called(1);
      verify(() => writer.write('s')).called(1);
      verify(() => writer.writeByte(3)).called(1);
      verify(() => writer.write('i')).called(1);
      verify(() => writer.writeByte(4)).called(1);
      verify(() => writer.write(DeviceTileType.boolean)).called(1);
      verify(() => writer.writeByte(5)).called(1);
      verify(() => writer.write('g')).called(1);
      verify(() => writer.writeByte(6)).called(1);
      verify(() => writer.write(1.0)).called(1);
      verify(() => writer.writeByte(7)).called(1);
      verify(() => writer.write(2.0)).called(1);
      verify(() => writer.writeByte(8)).called(1);
      verify(() => writer.write(3)).called(1);
      verify(() => writer.writeByte(9)).called(1);
      verify(() => writer.write(4.0)).called(1);
    });

    test('hashCode is typeId.hashCode', () {
      expect(adapter.hashCode, adapter.typeId.hashCode);
    });

    test('operator == returns true for same instance or same type', () {
      final adapter2 = DeviceModelAdapter();
      expect(adapter == adapter2, isTrue);
      expect(adapter == adapter, isTrue);
    });

    test('operator == returns false for different type', () {
      // ignore: unrelated_type_equality_checks // For test purposes
      expect(adapter == DeviceTileTypeAdapter(), isFalse);
    });
  });

  group('DeviceTileTypeAdapter', () {
    late DeviceTileTypeAdapter adapter;
    late MockBinaryReader reader;
    late MockBinaryWriter writer;

    setUp(() {
      adapter = DeviceTileTypeAdapter();
      reader = MockBinaryReader();
      writer = MockBinaryWriter();
    });

    test('typeId is 0', () {
      expect(adapter.typeId, 0);
    });

    test('read returns proper value for 0', () {
      when(() => reader.readByte()).thenReturn(0);
      expect(adapter.read(reader), DeviceTileType.boolean);
    });

    test('read returns proper value for 1', () {
      when(() => reader.readByte()).thenReturn(1);
      expect(adapter.read(reader), DeviceTileType.number);
    });

    test('read returns boolean as default for unknown value', () {
      when(() => reader.readByte()).thenReturn(2);
      expect(adapter.read(reader), DeviceTileType.boolean);
    });

    test('write boolean writes 0', () {
      adapter.write(writer, DeviceTileType.boolean);
      verify(() => writer.writeByte(0)).called(1);
    });

    test('write number writes 1', () {
      adapter.write(writer, DeviceTileType.number);
      verify(() => writer.writeByte(1)).called(1);
    });

    test('hashCode is typeId.hashCode', () {
      expect(adapter.hashCode, adapter.typeId.hashCode);
    });

    test('operator == returns true for same instance or same type', () {
      final adapter2 = DeviceTileTypeAdapter();
      expect(adapter == adapter2, isTrue);
      expect(adapter == adapter, isTrue);
    });

    test('operator == returns false for different type', () {
      // ignore: unrelated_type_equality_checks // For test purposes
      expect(adapter == DeviceModelAdapter(), isFalse);
    });
  });
}

class MockBinaryReader extends Mock implements BinaryReader {}

class MockBinaryWriter extends Mock implements BinaryWriter {}
