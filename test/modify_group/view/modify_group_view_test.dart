import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/modify_group/modify_group.dart';

class MockModifyGroupCubit extends MockCubit<ModifyGroupState>
    implements ModifyGroupCubit {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  group('ModifyGroupView', () {
    late ModifyGroupCubit modifyGroupCubit;

    setUp(() {
      modifyGroupCubit = MockModifyGroupCubit();

      when(() => modifyGroupCubit.state).thenReturn(
        ModifyGroupState(
          formKey: GlobalKey<FormState>(),
          icon: '',
        ),
      );

      when(() => modifyGroupCubit.saveGroupModel()).thenReturn(null);
      when(() => modifyGroupCubit.resetSaveStatus()).thenReturn(null);
    });

    Widget buildSubject() {
      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(),
            routes: [
              GoRoute(
                path: 'test',
                builder: (context, state) => const ModifyGroupView(),
              ),
            ],
          ),
        ],
      );

      return BlocProvider.value(
        value: modifyGroupCubit,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
    }

    testWidgets('triggers cubit methods on form interaction', (tester) async {
      await tester.pumpWidget(buildSubject());

      final appTextFields = find.byType(AppTextField);
      await tester.enterText(appTextFields.at(0), 'New Title');
      verify(() => modifyGroupCubit.changeTitle('New Title')).called(1);

      await tester.enterText(appTextFields.at(1), 'New Subtitle');
      verify(() => modifyGroupCubit.changeSubtitle('New Subtitle')).called(1);
    });

    testWidgets('triggers save on FAB tap', (tester) async {
      await tester.pumpWidget(buildSubject());

      final fab = find.byType(FloatingActionButton);
      tester.widget<FloatingActionButton>(fab).onPressed?.call();
      verify(() => modifyGroupCubit.saveGroupModel()).called(1);
    });

    testWidgets('shows success snackbar on save success', (tester) async {
      whenListen(
        modifyGroupCubit,
        Stream.fromIterable([
          ModifyGroupState(formKey: GlobalKey<FormState>(), title: 'Test'),
          ModifyGroupState(
            formKey: GlobalKey<FormState>(),
            title: 'Test',
            saveStatus: ModifyGroupStatus.success,
          ),
        ]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Test'), findsWidgets);
    });

    testWidgets('shows failure snackbar on save failure', (tester) async {
      whenListen(
        modifyGroupCubit,
        Stream.fromIterable([
          ModifyGroupState(formKey: GlobalKey<FormState>(), title: 'Test'),
          ModifyGroupState(
            formKey: GlobalKey<FormState>(),
            title: 'Test',
            saveStatus: ModifyGroupStatus.failure,
            modifyGroupError: ModifyGroupError.duplicateGroupName,
          ),
        ]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      verify(() => modifyGroupCubit.resetSaveStatus()).called(1);
    });
  });
}
