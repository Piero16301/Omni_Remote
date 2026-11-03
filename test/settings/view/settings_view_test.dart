import 'package:bloc_test/bloc_test.dart';
import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' hide ConnectionState;
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

      when(
        () => appCubit.changeLanguage(language: any(named: 'language')),
      ).thenReturn(null);
      when(
        () => appCubit.changeTheme(theme: any(named: 'theme')),
      ).thenReturn(null);
      when(
        () => appCubit.changeBaseColor(baseColor: any(named: 'baseColor')),
      ).thenReturn(null);
      when(
        () => appCubit.changeFontFamily(fontFamily: any(named: 'fontFamily')),
      ).thenReturn(null);
    });

    Widget buildSubject() {
      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
            routes: [
              GoRoute(
                path: 'test',
                builder: (context, state) => const SettingsView(),
              ),
            ],
          ),
        ],
      );

      return BlocProvider.value(
        value: appCubit,
        child: MaterialApp.router(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...ExpressiveLocalizations.localizationsDelegates,
          ],
          supportedLocales: ExpressiveLanguages.supportedLocales,
          routerConfig: router,
        ),
      );
    }

    testWidgets('renders all sections and tiles', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(SettingsView), findsOneWidget);
      expect(find.byType(ExpressiveTopAppBar), findsOneWidget);
      expect(find.byType(ExpressiveCardGroup), findsNWidgets(2));
      expect(find.byType(ExpressiveListTile), findsNWidgets(4));
      expect(find.byType(SettingsAppSpecs), findsOneWidget);
    });

    testWidgets('pops navigation when back button is tapped', (tester) async {
      await tester.pumpWidget(buildSubject());

      final backButton = find.byType(ExpressiveIconButton);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsView), findsNothing);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('triggers changeTheme when theme option selected from modal', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      final themeTile = find.widgetWithText(ExpressiveListTile, 'Theme');
      await tester.tap(themeTile);
      await tester.pumpAndSettle();

      final darkOption = find.widgetWithText(ListTile, 'Dark');
      await tester.tap(darkOption);
      await tester.pumpAndSettle();

      verify(() => appCubit.changeTheme(theme: ThemeMode.dark)).called(1);
    });

    testWidgets(
      'triggers changeBaseColor when color option selected from modal',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        final colorTile = find.widgetWithText(ExpressiveListTile, 'Base color');
        await tester.tap(colorTile);
        await tester.pumpAndSettle();

        final redOption = find.widgetWithText(ListTile, 'Red');
        await tester.tap(redOption);
        await tester.pumpAndSettle();

        verify(() => appCubit.changeBaseColor(baseColor: Colors.red)).called(1);
      },
    );

    testWidgets(
      'triggers changeFontFamily when font option selected from modal',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        final fontTile = find.widgetWithText(ExpressiveListTile, 'Font');
        await tester.tap(fontTile);
        await tester.pumpAndSettle();

        final fontOption = find.widgetWithText(ListTile, 'Merriweather');
        await tester.tap(fontOption);
        await tester.pumpAndSettle();

        verify(
          () => appCubit.changeFontFamily(
            fontFamily: ExpressiveFonts.merriweather,
          ),
        ).called(1);
      },
    );

    testWidgets(
      'triggers changeLanguage when language option selected from modal',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        final languageTile = find.widgetWithText(
          ExpressiveListTile,
          'Language',
        );
        await tester.tap(languageTile);
        await tester.pumpAndSettle();

        final spanishOption = find.widgetWithText(ListTile, 'Spanish');
        await tester.tap(spanishOption);
        await tester.pumpAndSettle();

        verify(
          () => appCubit.changeLanguage(language: ExpressiveLanguages.spanish),
        ).called(1);
      },
    );
  });
}
