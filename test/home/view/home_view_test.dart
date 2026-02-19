import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
      when(() => mockMqttService.messageStream)
          .thenAnswer((_) => const Stream.empty());
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

    Widget buildSubject() {
      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const Scaffold()),
          GoRoute(path: '/test', builder: (context, state) => const HomeView()),
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

    testWidgets('renders group cards and FAB when groups exist',
        (tester) async {
      groupsNotifier.value = [
        GroupModel(id: 'g1', title: 'Living Room', subtitle: '', icon: ''),
      ];
      await tester.pumpWidget(buildSubject());

      expect(find.byType(GroupCard), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

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
  });
}
