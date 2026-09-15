import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
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

    testWidgets('triggers cubit methods on number tile configuration fields', (
      tester,
    ) async {
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

    testWidgets('renders edit title when deviceModel is not null', (
      tester,
    ) async {
      when(() => modifyDeviceCubit.state).thenReturn(
        ModifyDeviceState(
          formKey: GlobalKey<FormState>(),
          icon: '',
          deviceModel: DeviceModel(
            id: 'd1',
            title: 'Dev',
            subtitle: '',
            groupId: 'g1',
            icon: '',
            tileType: DeviceTileType.boolean,
          ),
          selectedGroupId: 'g1',
        ),
      );

      await tester.pumpWidget(buildSubject());
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets(
      'renders number fields with non-zero rangeMin and null deviceModel',
      (tester) async {
        when(() => modifyDeviceCubit.state).thenReturn(
          ModifyDeviceState(
            formKey: GlobalKey<FormState>(),
            icon: '',
            tileType: DeviceTileType.number,
            selectedGroupId: 'g1',
            rangeMin: 5,
          ),
        );

        await tester.pumpWidget(buildSubject());
        expect(find.byType(AppTextField), findsWidgets);
      },
    );

    testWidgets('pops navigation when back button tapped', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();
    });

    testWidgets('triggers changeSelectedGroup on dropdown selection', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      final dropdown = tester.widget<AppDropdownField<String>>(
        find.byType(AppDropdownField<String>),
      );
      dropdown.onChanged?.call('g1');
      verify(() => modifyDeviceCubit.changeSelectedGroup('g1')).called(1);
    });

    testWidgets('title validator validates input correctly', (tester) async {
      await tester.pumpWidget(buildSubject());
      final titleField = tester.widget<AppTextField>(
        find.byType(AppTextField).first,
      );

      expect(titleField.validator?.call(null), isNotNull);
      expect(titleField.validator?.call(''), isNotNull);
      expect(titleField.validator?.call('Invalid@#%'), isNotNull);
      expect(titleField.validator?.call('Invalid  Spaces'), isNotNull);
      expect(titleField.validator?.call('Valid Title'), isNull);
    });

    testWidgets(
      'number tile configuration validators and initial values with deviceModel'
      ' and non-zero values',
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
            title: 'Test Device',
            rangeMin: 5,
            rangeMax: 20,
            divisions: 4,
            interval: 2,
            deviceModel: DeviceModel(
              id: 'd1',
              title: 'Dev',
              subtitle: '',
              groupId: 'g1',
              icon: '',
              tileType: DeviceTileType.number,
            ),
          ),
        );

        await tester.pumpWidget(buildSubject());

        final appTextFields = find.byType(AppTextField);
        expect(appTextFields.evaluate().length, 6);

        final rangeMinField = tester.widget<AppTextField>(appTextFields.at(2));
        final rangeMaxField = tester.widget<AppTextField>(appTextFields.at(3));
        final divisionsField = tester.widget<AppTextField>(appTextFields.at(4));
        final intervalField = tester.widget<AppTextField>(appTextFields.at(5));

        // rangeMin validator
        expect(rangeMinField.validator?.call(null), isNotNull);
        expect(rangeMinField.validator?.call(''), isNotNull);
        expect(rangeMinField.validator?.call('not_a_number'), isNotNull);
        expect(rangeMinField.validator?.call('25.0'), isNotNull);
        expect(rangeMinField.validator?.call('5.0'), isNull);

        // rangeMax validator
        expect(rangeMaxField.validator?.call(null), isNotNull);
        expect(rangeMaxField.validator?.call(''), isNotNull);
        expect(rangeMaxField.validator?.call('not_a_number'), isNotNull);
        expect(rangeMaxField.validator?.call('30.0'), isNull);

        // divisions validator
        expect(divisionsField.validator?.call(null), isNotNull);
        expect(divisionsField.validator?.call(''), isNotNull);
        expect(divisionsField.validator?.call('not_a_number'), isNotNull);
        expect(divisionsField.validator?.call('0'), isNotNull);
        expect(divisionsField.validator?.call('-1'), isNotNull);
        expect(divisionsField.validator?.call('5'), isNull);

        // interval validator
        expect(intervalField.validator?.call(null), isNotNull);
        expect(intervalField.validator?.call(''), isNotNull);
        expect(intervalField.validator?.call('not_a_number'), isNotNull);
        expect(intervalField.validator?.call('2.5'), isNull);

        // Enter invalid text into each number field to trigger tryParse == null
        // branch
        await tester.enterText(appTextFields.at(2), 'invalid');
        await tester.enterText(appTextFields.at(3), 'invalid');
        await tester.enterText(appTextFields.at(4), 'invalid');
        await tester.enterText(appTextFields.at(5), 'invalid');
      },
    );

    testWidgets('renders MqttTopicsInfo with empty groups fallback', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => modifyDeviceCubit.groups).thenReturn([]);
      when(() => modifyDeviceCubit.state).thenReturn(
        ModifyDeviceState(
          formKey: GlobalKey<FormState>(),
          icon: '',
          title: 'Device Title',
          selectedGroupId: 'unknown',
        ),
      );

      await tester.pumpWidget(buildSubject());
      expect(find.byType(MqttTopicsInfo), findsOneWidget);
    });

    testWidgets('getFailureMessage covers all enum values and orElse', (
      tester,
    ) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      const view = ModifyDeviceView();
      final groups = [
        GroupModel(id: 'g1', title: 'Group One', subtitle: '', icon: ''),
      ];

      // noGroupSelected
      expect(
        view.getFailureMessage(
          error: ModifyDeviceError.noGroupSelected,
          title: 'Dev',
          selectedGroupId: 'g1',
          l10n: l10n,
          groups: groups,
        ),
        equals(l10n.modifyDeviceSaveNoGroupSelectedError),
      );

      // duplicateDeviceName with group found
      expect(
        view.getFailureMessage(
          error: ModifyDeviceError.duplicateDeviceName,
          title: 'Dev',
          selectedGroupId: 'g1',
          l10n: l10n,
          groups: groups,
        ),
        equals(l10n.modifyDeviceSaveDuplicateError('Dev', 'Group One')),
      );

      // duplicateDeviceName with unknown group (triggers orElse)
      expect(
        view.getFailureMessage(
          error: ModifyDeviceError.duplicateDeviceName,
          title: 'Dev',
          selectedGroupId: 'unknown',
          l10n: l10n,
          groups: groups,
        ),
        equals(l10n.modifyDeviceSaveDuplicateError('Dev', '')),
      );

      // unknown
      expect(
        view.getFailureMessage(
          error: ModifyDeviceError.unknown,
          title: 'Dev',
          selectedGroupId: 'g1',
          l10n: l10n,
          groups: groups,
        ),
        equals(l10n.modifyDeviceSaveDefaultError('Dev')),
      );

      // none
      expect(
        view.getFailureMessage(
          error: ModifyDeviceError.none,
          title: 'Dev',
          selectedGroupId: 'g1',
          l10n: l10n,
          groups: groups,
        ),
        isEmpty,
      );
    });
  });
}
