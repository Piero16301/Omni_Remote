import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/home/home.dart';
import 'package:omni_remote/l10n/l10n.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  group('HomePage', () {
    late MockAppCubit mockAppCubit;

    setUp(() async {
      final mockLocalStorageService = MockLocalStorageService();
      mockAppCubit = MockAppCubit();
      when(() => mockAppCubit.state).thenReturn(const AppState());

      await getIt.reset();
      getIt.registerSingleton<LocalStorageService>(mockLocalStorageService);

      when(mockLocalStorageService.getGroups).thenReturn([]);
      when(mockLocalStorageService.getDevices).thenReturn([]);
      when(mockLocalStorageService.getGroupsListenable)
          .thenReturn(ValueNotifier<List<GroupModel>>([]));
      when(mockLocalStorageService.getDevicesListenable)
          .thenReturn(ValueNotifier<List<DeviceModel>>([]));
    });

    testWidgets('renders HomeView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<AppCubit>.value(
            value: mockAppCubit,
            child: const HomePage(),
          ),
        ),
      );
      expect(find.byType(HomeView), findsOneWidget);
    });
  });
}
