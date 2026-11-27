import 'package:bloc_test/bloc_test.dart';
import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/modify_device/modify_device.dart';
import 'package:omni_remote/modify_device/widgets/widgets.dart';

class MockLocalStorageService extends Mock implements LocalStorageService;

class MockAppCubit extends MockCubit<AppState> implements AppCubit;

class FakeDeviceModel extends Fake implements DeviceModel;

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDeviceModel());
  });

  group('ModifyDevicePage', () {
    late LocalStorageService mockLocalStorageService;
    late MockAppCubit mockAppCubit;

    setUp(() async {
      mockLocalStorageService = MockLocalStorageService();
      mockAppCubit = MockAppCubit();
      when(() => mockAppCubit.state).thenReturn(const AppState());

      await getIt.reset();
      setupServiceLocator(Environment.mock);
      await getIt.unregister<LocalStorageService>();
      getIt.registerSingleton<LocalStorageService>(mockLocalStorageService);

      when(() => mockLocalStorageService.getGroups()).thenReturn([
        GroupModel(id: '1', title: 'Test', subtitle: '', icon: ''),
      ]);
      when(() => mockLocalStorageService.getGroupsListenable()).thenReturn(
        ValueNotifier<List<GroupModel>>([
          GroupModel(id: '1', title: 'Test', subtitle: '', icon: ''),
        ]),
      );
      when(() => mockLocalStorageService.getDevicesListenable())
          .thenReturn(ValueNotifier<List<DeviceModel>>([]));
    });

    testWidgets('renders ModifyDeviceView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<AppCubit>.value(
            value: mockAppCubit,
            child: const ModifyDevicePage(),
          ),
        ),
      );
      expect(find.byType(ModifyDeviceView), findsOneWidget);
    });

    testWidgets('renders ModifyDeviceView with device provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<AppCubit>.value(
            value: mockAppCubit,
            child: ModifyDevicePage(
              device: DeviceModel(
                id: 'd1',
                title: 'Lamp',
                subtitle: '',
                groupId: '1',
                icon: '',
                tileType: DeviceTileType.boolean,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(ModifyDeviceView), findsOneWidget);
    });

    testWidgets(
      'validates empty title after scrolling to preview and toggling boolean',
      (tester) async {
        tester.view.physicalSize = const Size(400, 750);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider<AppCubit>.value(
              value: mockAppCubit,
              child: const ModifyDevicePage(),
            ),
          ),
        );

        await tester.scrollUntilVisible(
          find.byType(DevicePreview),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ExpressiveSwitch));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ExpressiveFab));
        await tester.pumpAndSettle();

        verifyNever(
          () => mockLocalStorageService.createDevice(
            device: any(named: 'device'),
          ),
        );
        expect(find.text('Title cannot be empty'), findsOneWidget);
      },
    );

    testWidgets(
      'validates empty title after switching to number and changing preview',
      (tester) async {
        tester.view.physicalSize = const Size(400, 750);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider<AppCubit>.value(
              value: mockAppCubit,
              child: const ModifyDevicePage(),
            ),
          ),
        );

        await tester.scrollUntilVisible(
          find.byType(ExpressiveButtonGroup<DeviceTileType>),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Number'));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.byType(ExpressiveSlider),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        final slider = tester.widget<ExpressiveSlider>(
          find.byType(ExpressiveSlider),
        );
        slider.onChanged?.call(8);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ExpressiveFab));
        await tester.pumpAndSettle();

        verifyNever(
          () => mockLocalStorageService.createDevice(
            device: any(named: 'device'),
          ),
        );
        expect(find.text('Title cannot be empty'), findsOneWidget);
      },
    );
  });
}
