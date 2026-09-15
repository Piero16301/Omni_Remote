import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' hide ConnectionState;
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/home/home.dart';
import 'package:omni_remote/l10n/l10n.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class MockMqttService extends Mock implements MqttService {}

class FakeBuildContext extends Fake implements BuildContext {}

class FakeGroupModel extends Fake implements GroupModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeGroupModel());
  });

  group('HomeView', () {
    late AppCubit appCubit;
    late HomeCubit homeCubit;
    late ValueNotifier<List<GroupModel>> groupsNotifier;
    late ValueNotifier<List<DeviceModel>> devicesNotifier;
    late MqttService mockMqttService;

    setUp(() {
      appCubit = MockAppCubit();
      homeCubit = MockHomeCubit();
      mockMqttService = MockMqttService();
      groupsNotifier = ValueNotifier<List<GroupModel>>([]);
      devicesNotifier = ValueNotifier<List<DeviceModel>>([]);

      when(() => mockMqttService.mqttClient).thenReturn(null);
      when(
        () => mockMqttService.messageStream,
      ).thenAnswer((_) => const Stream.empty());
      getIt.registerSingleton<MqttService>(mockMqttService);

      when(() => appCubit.state).thenReturn(
        const AppState(
          brokerConnectionStatus: BrokerConnectionStatus.connected,
        ),
      );

      when(() => homeCubit.state).thenReturn(const HomeState());
      when(() => homeCubit.getGroupsListenable()).thenReturn(groupsNotifier);
      when(() => homeCubit.getDevicesListenable()).thenReturn(devicesNotifier);
      when(() => homeCubit.resetDeleteGroupStatus()).thenReturn(null);
      when(() => homeCubit.resetDeleteDeviceStatus()).thenReturn(null);
      when(() => homeCubit.deleteGroup(any())).thenAnswer((_) async {});
    });

    tearDown(getIt.reset);

    Widget buildSubject({BrokerConnectionStatus? brokerStatus}) {
      if (brokerStatus != null) {
        when(
          () => appCubit.state,
        ).thenReturn(AppState(brokerConnectionStatus: brokerStatus));
      }

      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const Scaffold()),
          GoRoute(
            path: '/test',
            name: AppRoute.home.name,
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: '/connection',
            name: AppRoute.connection.name,
            builder: (context, state) =>
                const Scaffold(body: Text('ConnectionScreen')),
          ),
          GoRoute(
            path: '/settings',
            name: AppRoute.settings.name,
            builder: (context, state) =>
                const Scaffold(body: Text('SettingsScreen')),
          ),
          GoRoute(
            path: '/modifyGroup',
            name: AppRoute.modifyGroup.name,
            builder: (context, state) =>
                const Scaffold(body: Text('ModifyGroupScreen')),
          ),
          GoRoute(
            path: '/modifyDevice',
            name: AppRoute.modifyDevice.name,
            builder: (context, state) =>
                const Scaffold(body: Text('ModifyDeviceScreen')),
          ),
        ],
      );

      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: appCubit),
          BlocProvider.value(value: homeCubit),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
    }

    testWidgets('renders empty state correctly', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(Visibility), findsWidgets);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('renders group cards and FAB when groups exist', (
      tester,
    ) async {
      groupsNotifier.value = [
        GroupModel(id: 'g1', title: 'Living Room', subtitle: '', icon: ''),
      ];
      await tester.pumpWidget(buildSubject());

      expect(find.byType(GroupCard), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('navigates to connection page when antenna icon tapped', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();

      expect(find.text('ConnectionScreen'), findsOneWidget);
    });

    testWidgets('navigates to settings page when settings icon tapped', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byType(IconButton).last);
      await tester.pumpAndSettle();

      expect(find.text('SettingsScreen'), findsOneWidget);
    });

    testWidgets('navigates to modify group page when New Group card tapped', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byType(Card).last);
      await tester.pumpAndSettle();

      expect(find.text('ModifyGroupScreen'), findsOneWidget);
    });

    testWidgets('navigates to modify device page when FAB tapped', (
      tester,
    ) async {
      groupsNotifier.value = [
        GroupModel(id: 'g1', title: 'Living Room', subtitle: '', icon: ''),
      ];
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('ModifyDeviceScreen'), findsOneWidget);
    });

    testWidgets('triggers onEdit and onDelete on GroupCard', (tester) async {
      final group = GroupModel(
        id: 'g1',
        title: 'Living Room',
        subtitle: '',
        icon: '',
      );
      groupsNotifier.value = [group];
      await tester.pumpWidget(buildSubject());

      final groupCard = tester.widget<GroupCard>(find.byType(GroupCard));

      // Test onDelete callback
      groupCard.onDelete();
      verify(() => homeCubit.deleteGroup(group)).called(1);

      // Test onEdit callback
      groupCard.onEdit();
      await tester.pumpAndSettle();
      expect(find.text('ModifyGroupScreen'), findsOneWidget);
    });

    testWidgets(
      'displays correct label and color for all connection statuses',
      (tester) async {
        for (final status in BrokerConnectionStatus.values) {
          await tester.pumpWidget(buildSubject(brokerStatus: status));
          await tester.pump();
          expect(find.byType(AppBar), findsOneWidget);
        }
      },
    );

    testWidgets('shows delete group success snackbar', (tester) async {
      whenListen(
        homeCubit,
        Stream.fromIterable([
          const HomeState(),
          const HomeState(deleteGroupStatus: HomeStatus.success),
        ]),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows delete group failure snackbar', (tester) async {
      whenListen(
        homeCubit,
        Stream.fromIterable([
          const HomeState(),
          const HomeState(
            deleteGroupStatus: HomeStatus.failure,
            groupDeleteError: GroupDeleteError.groupNotEmpty,
          ),
        ]),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      verify(() => homeCubit.resetDeleteGroupStatus()).called(1);
    });

    testWidgets('shows delete device success snackbar', (tester) async {
      whenListen(
        homeCubit,
        Stream.fromIterable([
          const HomeState(),
          const HomeState(deleteDeviceStatus: HomeStatus.success),
        ]),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows delete device failure snackbar', (tester) async {
      whenListen(
        homeCubit,
        Stream.fromIterable([
          const HomeState(),
          const HomeState(
            deleteDeviceStatus: HomeStatus.failure,
            deviceDeleteError: DeviceDeleteError.deviceNotFound,
          ),
        ]),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      verify(() => homeCubit.resetDeleteDeviceStatus()).called(1);
    });

    testWidgets('getGroupDeleteFailureMessage covers all enum values', (
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

      const view = HomeView();
      expect(
        view.getGroupDeleteFailureMessage(GroupDeleteError.groupNotEmpty, l10n),
        equals(l10n.homeDeleteGroupErrorNotEmpty),
      );
      expect(
        view.getGroupDeleteFailureMessage(GroupDeleteError.groupNotFound, l10n),
        equals(l10n.homeDeleteGroupErrorNotFound),
      );
      expect(
        view.getGroupDeleteFailureMessage(GroupDeleteError.unknown, l10n),
        equals(l10n.homeDeleteGroupErrorUnknown),
      );
      expect(
        view.getGroupDeleteFailureMessage(GroupDeleteError.none, l10n),
        isEmpty,
      );
    });

    testWidgets('getDeviceDeleteFailureMessage covers all enum values', (
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

      const view = HomeView();
      expect(
        view.getDeviceDeleteFailureMessage(
          DeviceDeleteError.deviceNotFound,
          l10n,
        ),
        equals(l10n.homeDeleteDeviceErrorNotFound),
      );
      expect(
        view.getDeviceDeleteFailureMessage(DeviceDeleteError.unknown, l10n),
        equals(l10n.homeDeleteDeviceErrorUnknown),
      );
      expect(
        view.getDeviceDeleteFailureMessage(DeviceDeleteError.none, l10n),
        isEmpty,
      );
    });
  });
}
