import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/modify_group/modify_group.dart';

void main() {
  group('ModifyGroupStatus', () {
    test('returns correct flags', () {
      expect(ModifyGroupStatus.initial.isInitial, isTrue);
      expect(ModifyGroupStatus.loading.isLoading, isTrue);
      expect(ModifyGroupStatus.success.isSuccess, isTrue);
      expect(ModifyGroupStatus.failure.isFailure, isTrue);
    });
  });

  group('ModifyGroupState', () {
    const formKey = GlobalObjectKey<FormState>('modify_group_form_test');

    test('supports value equality', () {
      expect(
        const ModifyGroupState(),
        const ModifyGroupState(),
      );
    });

    test('props are correct', () {
      const state = ModifyGroupState();
      expect(
        state.props,
        <Object?>[
          '', // title
          '', // subtitle
          IconHelper.getGroupFirstIcon, // icon
          state.formKey, // formKey
          null, // groupModel
          ModifyGroupStatus.initial, // saveStatus
          ModifyGroupError.none, // modifyGroupError
        ],
      );
    });

    test('copyWith returns object with updated properties', () {
      final mockGroup = GroupModel(
        id: '1',
        title: 'Group 1',
        subtitle: 'Desc',
        icon: 'GROUP',
      );

      final state = const ModifyGroupState().copyWith(
        title: 'New Title',
        subtitle: 'New Subtitle',
        icon: 'NEW_ICON',
        formKey: formKey,
        groupModel: mockGroup,
        saveStatus: ModifyGroupStatus.success,
        modifyGroupError: ModifyGroupError.duplicateGroupName,
      );

      expect(
        state,
        ModifyGroupState(
          title: 'New Title',
          subtitle: 'New Subtitle',
          icon: 'NEW_ICON',
          formKey: formKey,
          groupModel: mockGroup,
          saveStatus: ModifyGroupStatus.success,
          modifyGroupError: ModifyGroupError.duplicateGroupName,
        ),
      );
    });
  });
}
