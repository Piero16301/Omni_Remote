import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/modify_group/modify_group.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ModifyGroupCubit', () {
    late LocalStorageService mockLocalStorageService;
    late ModifyGroupCubit cubit;

    setUp(() {
      mockLocalStorageService = MockLocalStorageService();
      getIt.registerSingleton<LocalStorageService>(mockLocalStorageService);

      cubit = ModifyGroupCubit();
    });

    tearDown(() {
      unawaited(cubit.close());
      unawaited(getIt.reset());
    });

    test('initial state properties', () {
      expect(cubit.state.saveStatus, ModifyGroupStatus.initial);
      expect(cubit.state.groupModel, isNull);
    });

    blocTest<ModifyGroupCubit, ModifyGroupState>(
      'groupReceived updates state correctly',
      build: () => cubit,
      act: (cubit) => cubit.groupReceived(
        GroupModel(
          id: 'grp_01',
          title: 'Office',
          subtitle: 'Work area',
          icon: 'OFFICE',
        ),
      ),
      expect: () => [
        isA<ModifyGroupState>()
            .having((s) => s.title, 'title', 'Office')
            .having((s) => s.subtitle, 'subtitle', 'Work area')
            .having((s) => s.icon, 'icon', 'OFFICE')
            .having((s) => s.groupModel, 'model', isNotNull),
      ],
    );

    blocTest<ModifyGroupCubit, ModifyGroupState>(
      'changeTitle updates title',
      build: () => cubit,
      act: (cubit) => cubit.changeTitle('New Office'),
      expect: () => [
        isA<ModifyGroupState>().having((s) => s.title, 'title', 'New Office'),
      ],
    );

    blocTest<ModifyGroupCubit, ModifyGroupState>(
      'resetSaveStatus updates to initial',
      build: () => cubit,
      seed: () => const ModifyGroupState(saveStatus: ModifyGroupStatus.success),
      act: (cubit) => cubit.resetSaveStatus(),
      expect: () => [
        isA<ModifyGroupState>()
            .having((s) => s.saveStatus, 'status', ModifyGroupStatus.initial),
      ],
    );
  });
}
