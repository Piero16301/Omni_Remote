import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/modify_group/modify_group.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

class FakeGroupModel extends Fake implements GroupModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGroupModel());
  });

  group('ModifyGroupCubit', () {
    late LocalStorageService mockLocalStorageService;

    setUp(() async {
      mockLocalStorageService = MockLocalStorageService();
      if (!getIt.isRegistered<LocalStorageService>()) {
        getIt.registerSingleton<LocalStorageService>(mockLocalStorageService);
      } else {
        await getIt.unregister<LocalStorageService>();
        getIt.registerSingleton<LocalStorageService>(mockLocalStorageService);
      }
    });

    tearDown(() {
      unawaited(getIt.reset());
    });

    test('initial state is correct', () {
      final cubit = ModifyGroupCubit();
      expect(cubit.state, const ModifyGroupState());
      unawaited(cubit.close());
    });

    blocTest<ModifyGroupCubit, ModifyGroupState>(
      'groupReceived updates state correctly when group is null',
      build: ModifyGroupCubit.new,
      act: (cubit) => cubit.groupReceived(null),
      expect: () => [
        isA<ModifyGroupState>()
            .having((s) => s.title, 'title', '')
            .having((s) => s.subtitle, 'subtitle', '')
            .having((s) => s.icon, 'icon', IconHelper.getGroupFirstIcon)
            .having((s) => s.groupModel, 'groupModel', isNull),
      ],
    );

    blocTest<ModifyGroupCubit, ModifyGroupState>(
      'groupReceived updates state correctly with group',
      build: ModifyGroupCubit.new,
      act: (cubit) => cubit.groupReceived(
        GroupModel(
          id: 'g1',
          title: 'Group 1',
          subtitle: 'Sub group',
          icon: 'icon1',
        ),
      ),
      expect: () => [
        isA<ModifyGroupState>()
            .having((s) => s.title, 'title', 'Group 1')
            .having((s) => s.subtitle, 'subtitle', 'Sub group')
            .having((s) => s.icon, 'icon', 'icon1')
            .having((s) => s.groupModel?.id, 'groupModel', 'g1'),
      ],
    );

    blocTest<ModifyGroupCubit, ModifyGroupState>(
      'change properties updates state correctly',
      build: ModifyGroupCubit.new,
      act: (cubit) {
        cubit
          ..changeTitle('New Title')
          ..changeSubtitle('New Sub')
          ..changeIcon('New Icon');
      },
      expect: () => [
        isA<ModifyGroupState>().having((s) => s.title, 'title', 'New Title'),
        isA<ModifyGroupState>()
            .having((s) => s.subtitle, 'subtitle', 'New Sub'),
        isA<ModifyGroupState>().having((s) => s.icon, 'icon', 'New Icon'),
      ],
    );

    testWidgets('saveGroupModel fails validation', (tester) async {
      final cubit = ModifyGroupCubit();

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

      cubit.saveGroupModel();

      expect(cubit.state.saveStatus, ModifyGroupStatus.initial);
      unawaited(cubit.close());
    });

    testWidgets('saveGroupModel creates new group', (tester) async {
      final cubit = ModifyGroupCubit();
      when(
        () => mockLocalStorageService.createGroup(group: any(named: 'group')),
      ).thenAnswer((_) async {});

      cubit.groupReceived(null);

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

      cubit.saveGroupModel();

      expect(cubit.state.saveStatus, ModifyGroupStatus.success);
      verify(
        () => mockLocalStorageService.createGroup(group: any(named: 'group')),
      ).called(1);
      unawaited(cubit.close());
    });

    testWidgets('saveGroupModel updates existing group', (tester) async {
      final cubit = ModifyGroupCubit();
      when(
        () => mockLocalStorageService.updateGroup(group: any(named: 'group')),
      ).thenAnswer((_) async {});

      cubit.groupReceived(
        GroupModel(id: 'g1', title: 'T', subtitle: '', icon: ''),
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

      cubit.saveGroupModel();

      expect(cubit.state.saveStatus, ModifyGroupStatus.success);
      verify(
        () => mockLocalStorageService.updateGroup(group: any(named: 'group')),
      ).called(1);
      unawaited(cubit.close());
    });

    testWidgets('saveGroupModel handles duplicate name error', (tester) async {
      final cubit = ModifyGroupCubit();
      when(
        () => mockLocalStorageService.createGroup(group: any(named: 'group')),
      ).thenThrow(Exception('DUPLICATE_GROUP_NAME'));

      cubit.groupReceived(null);

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

      cubit.saveGroupModel();

      expect(cubit.state.saveStatus, ModifyGroupStatus.failure);
      expect(cubit.state.modifyGroupError, ModifyGroupError.duplicateGroupName);
      unawaited(cubit.close());
    });

    testWidgets('saveGroupModel handles unknown error', (tester) async {
      final cubit = ModifyGroupCubit();
      when(
        () => mockLocalStorageService.createGroup(group: any(named: 'group')),
      ).thenThrow(Exception('UNKNOWN_ERROR'));

      cubit.groupReceived(null);

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

      cubit.saveGroupModel();

      expect(cubit.state.saveStatus, ModifyGroupStatus.failure);
      expect(cubit.state.modifyGroupError, ModifyGroupError.unknown);
      unawaited(cubit.close());
    });
  });
}
