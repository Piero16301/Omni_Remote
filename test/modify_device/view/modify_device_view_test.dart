import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/modify_device/modify_device.dart';

class MockModifyDeviceCubit extends MockCubit<ModifyDeviceState>
    implements ModifyDeviceCubit {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  group('ModifyDeviceView', () {
    late ModifyDeviceCubit modifyDeviceCubit;
    late List<GroupModel> mockGroups;

    setUp(() {
      modifyDeviceCubit = MockModifyDeviceCubit();
      mockGroups = [
        GroupModel(id: 'g1', title: 'Group 1', subtitle: '', icon: ''),
      ];

      when(() => modifyDeviceCubit.groups).thenReturn(mockGroups);

      when(() => modifyDeviceCubit.state).thenReturn(
        ModifyDeviceState(
          formKey: GlobalKey<FormState>(),
          icon: '',
          tileType: DeviceTileType.number,
          selectedGroupId: 'g1',
        ),
      );

      when(() => modifyDeviceCubit.saveDeviceModel()).thenReturn(null);
      when(() => modifyDeviceCubit.resetSaveStatus()).thenReturn(null);
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
                builder: (context, state) => const ModifyDeviceView(),
              ),
            ],
          ),
        ],
      );

      return BlocProvider.value(
        value: modifyDeviceCubit,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
    }

    testWidgets('triggers cubit methods on form interaction', (tester) async {
      when(() => modifyDeviceCubit.state).thenReturn(
        ModifyDeviceState(
          formKey: GlobalKey<FormState>(),
          icon: '',
          selectedGroupId: 'g1',
        ),
      );

      await tester.pumpWidget(buildSubject());

      final appTextFields = find.byType(AppTextField);
      await tester.enterText(appTextFields.at(0), 'New Title');
      verify(() => modifyDeviceCubit.changeTitle('New Title')).called(1);

      await tester.enterText(appTextFields.at(1), 'New Subtitle');
      verify(() => modifyDeviceCubit.changeSubtitle('New Subtitle')).called(1);
    });

    testWidgets('triggers cubit methods on number tile configuration fields',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => modifyDeviceCubit.state).thenReturn(
        ModifyDeviceState(
          formKey: GlobalKey<FormState>(),
          icon: '',
          tileType: DeviceTileType.number,
          selectedGroupId: 'g1',
        ),
      );

      await tester.pumpWidget(buildSubject());

      final appTextFields = find.byType(AppTextField);
      expect(appTextFields.evaluate().length, 6);

      await tester.enterText(appTextFields.at(2), '1.0');
      verify(() => modifyDeviceCubit.changeRangeMin(1)).called(1);

      await tester.enterText(appTextFields.at(3), '10.0');
      verify(() => modifyDeviceCubit.changeRangeMax(10)).called(1);

      await tester.enterText(appTextFields.at(4), '5');
      verify(() => modifyDeviceCubit.changeDivisions(5)).called(1);

      await tester.enterText(appTextFields.at(5), '2.0');
      verify(() => modifyDeviceCubit.changeInterval(2)).called(1);
    });

    testWidgets('triggers save on FAB tap', (tester) async {
      await tester.pumpWidget(buildSubject());

      final fab = find.byType(FloatingActionButton);
      tester.widget<FloatingActionButton>(fab).onPressed?.call();
      verify(() => modifyDeviceCubit.saveDeviceModel()).called(1);
    });

    testWidgets('shows success snackbar on save success', (tester) async {
      whenListen(
        modifyDeviceCubit,
        Stream.fromIterable([
          ModifyDeviceState(formKey: GlobalKey<FormState>(), title: 'Test'),
          ModifyDeviceState(
            formKey: GlobalKey<FormState>(),
            title: 'Test',
            saveStatus: ModifyDeviceStatus.success,
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
        modifyDeviceCubit,
        Stream.fromIterable([
          ModifyDeviceState(formKey: GlobalKey<FormState>(), title: 'Test'),
          ModifyDeviceState(
            formKey: GlobalKey<FormState>(),
            title: 'Test',
            saveStatus: ModifyDeviceStatus.failure,
            modifyDeviceError: ModifyDeviceError.duplicateDeviceName,
            selectedGroupId: 'g1',
          ),
        ]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      verify(() => modifyDeviceCubit.resetSaveStatus()).called(1);
    });
  });
}
