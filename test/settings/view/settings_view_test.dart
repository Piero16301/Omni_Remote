import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/settings/settings.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(const Locale('en'));
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(Colors.blue);
  });

  group('SettingsView', () {
    late AppCubit appCubit;

    setUp(() {
      appCubit = MockAppCubit();
      when(() => appCubit.state).thenReturn(const AppState());

      when(() => appCubit.changeLanguage(language: any(named: 'language')))
          .thenReturn(null);
      when(() => appCubit.changeTheme(theme: any(named: 'theme')))
          .thenReturn(null);
      when(() => appCubit.changeBaseColor(baseColor: any(named: 'baseColor')))
          .thenReturn(null);
      when(
        () => appCubit.changeFontFamily(fontFamily: any(named: 'fontFamily')),
      ).thenReturn(null);
    });

    Widget buildSubject() {
      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const Scaffold()),
          GoRoute(
            path: '/test',
            builder: (context, state) => const SettingsView(),
          ),
        ],
      );

      return BlocProvider.value(
        value: appCubit,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
    }

    testWidgets('renders all settings cards', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(LocaleSettingsCard), findsOneWidget);
      expect(find.byType(ThemeSettingsCard), findsOneWidget);
      expect(find.byType(ColorSettingsCard), findsOneWidget);
      expect(find.byType(FontSettingsCard), findsOneWidget);
      expect(find.byType(SettingsAppSpecs), findsOneWidget);
    });

    testWidgets('triggers AppCubit methods on changes', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildSubject());

      final localeDropdown = find.descendant(
        of: find.byType(LocaleSettingsCard),
        matching: find.byType(DropdownButton<Locale>),
      );
      tester
          .widget<DropdownButton<Locale>>(localeDropdown)
          .onChanged
          ?.call(const Locale('es'));
      verify(() => appCubit.changeLanguage(language: const Locale('es')))
          .called(1);

      final themeDropdown = find.descendant(
        of: find.byType(ThemeSettingsCard),
        matching: find.byType(DropdownButton<ThemeMode>),
      );
      tester
          .widget<DropdownButton<ThemeMode>>(themeDropdown)
          .onChanged
          ?.call(ThemeMode.dark);
      verify(() => appCubit.changeTheme(theme: ThemeMode.dark)).called(1);

      final colorDropdown = find.descendant(
        of: find.byType(ColorSettingsCard),
        matching: find.byType(DropdownButton<Color>),
      );
      tester
          .widget<DropdownButton<Color>>(colorDropdown)
          .onChanged
          ?.call(Colors.red);
      verify(() => appCubit.changeBaseColor(baseColor: Colors.red)).called(1);

      final fontDropdown = find.descendant(
        of: find.byType(FontSettingsCard),
        matching: find.byType(DropdownButton<String>),
      );
      tester
          .widget<DropdownButton<String>>(fontDropdown)
          .onChanged
          ?.call('Roboto');
      verify(() => appCubit.changeFontFamily(fontFamily: 'Roboto')).called(1);
    });
  });
}
