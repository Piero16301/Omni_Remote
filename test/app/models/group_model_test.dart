import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/models/group_model.dart';

void main() {
  group('GroupModel', () {
    test('instantiates correctly and properties are set', () {
      final group = GroupModel(
        title: 'Living Room',
        subtitle: 'Main area',
        icon: '0xe456',
        id: 'group_id',
      );

      expect(group.title, 'Living Room');
      expect(group.subtitle, 'Main area');
      expect(group.icon, '0xe456');
      expect(group.id, 'group_id');
    });

    test('copyWith creates a new instance with updated values', () {
      final group = GroupModel(
        title: 'Living Room',
        subtitle: 'Main area',
        icon: '0xe456',
        id: 'group_id',
      );

      final updatedGroup = group.copyWith(
        title: 'Kitchen',
        subtitle: 'Cooking area',
        icon: '0xe789',
        id: 'new_group_id',
      );

      expect(updatedGroup.title, 'Kitchen');
      expect(updatedGroup.subtitle, 'Cooking area');
      expect(updatedGroup.icon, '0xe789');
      expect(updatedGroup.id, 'new_group_id');
    });

    test('copyWith with no arguments returns a copy with the same values', () {
      final group = GroupModel(
        title: 'Living Room',
        subtitle: 'Main area',
        icon: '0xe456',
        id: 'group_id',
      );

      final updatedGroup = group.copyWith();

      expect(updatedGroup.title, group.title);
      expect(updatedGroup.subtitle, group.subtitle);
      expect(updatedGroup.icon, group.icon);
      expect(updatedGroup.id, group.id);
    });
  });

  group('GroupModelAdapter', () {
    late GroupModelAdapter adapter;
    late MockBinaryReader reader;
    late MockBinaryWriter writer;

    setUp(() {
      adapter = GroupModelAdapter();
      reader = MockBinaryReader();
      writer = MockBinaryWriter();
    });

    test('typeId is 2', () {
      expect(adapter.typeId, 2);
    });

    test('read returns valid GroupModel with non-null fields', () {
      var byteCount = 0;
      when(() => reader.readByte()).thenAnswer((_) {
        if (byteCount == 0) {
          byteCount++;
          return 4;
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
    });

    test('read returns valid GroupModel with null fields', () {
      var byteCount = 0;
      when(() => reader.readByte()).thenAnswer((_) {
        if (byteCount == 0) {
          byteCount++;
          return 4;
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
    });

    test('write assigns correct values', () {
      final groupModel = GroupModel(
        title: 't',
        subtitle: 's',
        icon: 'i',
        id: 'id1',
      );

      adapter.write(writer, groupModel);

      verify(() => writer.writeByte(4)).called(1);
      verify(() => writer.writeByte(0)).called(1);
      verify(() => writer.write('id1')).called(1);
      verify(() => writer.writeByte(1)).called(1);
      verify(() => writer.write('t')).called(1);
      verify(() => writer.writeByte(2)).called(1);
      verify(() => writer.write('s')).called(1);
      verify(() => writer.writeByte(3)).called(1);
      verify(() => writer.write('i')).called(1);
    });

    test('hashCode is typeId.hashCode', () {
      expect(adapter.hashCode, adapter.typeId.hashCode);
    });

    test('operator == returns true for same instance or same type', () {
      final adapter2 = GroupModelAdapter();
      expect(adapter == adapter2, isTrue);
      expect(adapter == adapter, isTrue);
    });

    test('operator == returns false for different type', () {
      // ignore: unrelated_type_equality_checks // For test purposes
      expect(adapter == MockBinaryReader(), isFalse);
    });
  });
}

class MockBinaryReader extends Mock implements BinaryReader {}

class MockBinaryWriter extends Mock implements BinaryWriter {}
