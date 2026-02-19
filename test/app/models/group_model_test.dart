import 'package:flutter_test/flutter_test.dart';
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
  });
}
