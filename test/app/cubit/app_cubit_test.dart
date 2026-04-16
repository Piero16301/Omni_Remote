import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockMqttService extends Mock implements MqttService {}

class MockCrashService extends Mock implements CrashService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AppCubit', () {
    late LocalStorageService mockLocalStorageService;
    late MqttService mockMqttService;
    late CrashService mockCrashService;
    late AnalyticsService mockAnalyticsService;
    late AppCubit appCubit;

    setUpAll(() {
      registerFallbackValue(const Locale('en', 'US'));
      registerFallbackValue(ThemeMode.system);
      registerFallbackValue(Colors.black);
      registerFallbackValue(<String, Object>{});
    });

    setUp(() async {
      mockLocalStorageService = MockLocalStorageService();
      mockMqttService = MockMqttService();
      mockCrashService = MockCrashService();
      mockAnalyticsService = MockAnalyticsService();

      await getIt.reset();
      setupServiceLocator(Environment.mock);

      getIt
        ..unregister<LocalStorageService>()
        ..registerSingleton<LocalStorageService>(mockLocalStorageService)
        ..unregister<MqttService>()
        ..registerSingleton<MqttService>(mockMqttService)
        ..unregister<CrashService>()
        ..registerSingleton<CrashService>(mockCrashService)
        ..unregister<AnalyticsService>()
        ..registerSingleton<AnalyticsService>(mockAnalyticsService);

      when(() => mockLocalStorageService.getLanguage()).thenReturn(null);
      when(() => mockLocalStorageService.getTheme()).thenReturn(null);
      when(() => mockLocalStorageService.getBaseColor()).thenReturn(null);
      when(() => mockLocalStorageService.getFontFamily()).thenReturn(null);

      when(() => mockCrashService.setCustomKey(any(), any())).thenReturn(null);

      appCubit = AppCubit();
    });

    tearDown(() {
      unawaited(appCubit.close());
      unawaited(getIt.reset());
    });

    test('initial state is correct', () {
      expect(appCubit.state, const AppState());
    });

    blocTest<AppCubit, AppState>(
      'initialize emits state with updated configuration',
      build: () => appCubit,
      act: (cubit) => cubit.initialize(),
      verify: (_) {
        verify(
          () => mockLocalStorageService.saveLanguage(
            language: any<Locale>(named: 'language'),
          ),
        ).called(1);
        verify(() => mockLocalStorageService.saveTheme(theme: ThemeMode.system))
            .called(1);
        verify(
          () => mockLocalStorageService.saveBaseColor(
            baseColor: AppVariables.defaultBaseColor,
          ),
        ).called(1);
      },
    );

    blocTest<AppCubit, AppState>(
      'changeLanguage acts and emits correct state',
      build: () => appCubit,
      act: (cubit) => cubit.changeLanguage(language: const Locale('es', 'ES')),
      expect: () => [
        isA<AppState>()
            .having((s) => s.language, 'language', const Locale('es', 'ES')),
      ],
      verify: (_) {
        verify(
          () => mockLocalStorageService.saveLanguage(
            language: const Locale('es', 'ES'),
          ),
        ).called(1);
        verify(
          () => mockAnalyticsService.logEvent(
            name: 'change_language',
            parameters: any<Map<String, Object>?>(named: 'parameters'),
          ),
        ).called(1);
      },
    );

    blocTest<AppCubit, AppState>(
      'changeTheme acts and emits correct state',
      build: () => appCubit,
      act: (cubit) => cubit.changeTheme(theme: ThemeMode.dark),
      expect: () => [
        isA<AppState>().having((s) => s.theme, 'theme', ThemeMode.dark),
      ],
      verify: (_) {
        verify(() => mockLocalStorageService.saveTheme(theme: ThemeMode.dark))
            .called(1);
        verify(
          () => mockAnalyticsService.logEvent(
            name: 'change_theme',
            parameters: any<Map<String, Object>?>(named: 'parameters'),
          ),
        ).called(1);
      },
    );

    blocTest<AppCubit, AppState>(
      'changeBaseColor acts and emits correct state',
      build: () => appCubit,
      act: (cubit) => cubit.changeBaseColor(baseColor: Colors.blue),
      expect: () => [
        isA<AppState>().having((s) => s.baseColor, 'color', Colors.blue),
      ],
      verify: (_) {
        verify(
          () => mockLocalStorageService.saveBaseColor(baseColor: Colors.blue),
        ).called(1);
        verify(
          () => mockAnalyticsService.logEvent(
            name: 'change_base_color',
            parameters: any<Map<String, Object>?>(named: 'parameters'),
          ),
        ).called(1);
      },
    );

    blocTest<AppCubit, AppState>(
      'changeFontFamily acts and emits correct state',
      build: () => appCubit,
      act: (cubit) => cubit.changeFontFamily(fontFamily: 'Roboto'),
      expect: () => [
        isA<AppState>().having((s) => s.fontFamily, 'font', 'Roboto'),
      ],
      verify: (_) {
        verify(
          () => mockLocalStorageService.saveFontFamily(fontFamily: 'Roboto'),
        ).called(1);
        verify(
          () => mockAnalyticsService.logEvent(
            name: 'change_font_family',
            parameters: any<Map<String, Object>?>(named: 'parameters'),
          ),
        ).called(1);
      },
    );

    blocTest<AppCubit, AppState>(
      'initializeMqttClient starts listening to connectionStatusStream',
      build: () {
        when(() => mockMqttService.connectionStatusStream).thenAnswer(
          (_) => Stream.fromIterable([BrokerConnectionStatus.connected]),
        );
        when(() => mockMqttService.initializeMqttClient())
            .thenAnswer((_) async {});
        return appCubit;
      },
      act: (cubit) => cubit.initializeMqttClient(),
      expect: () => [
        isA<AppState>().having(
          (s) => s.brokerConnectionStatus,
          'status',
          BrokerConnectionStatus.connected,
        ),
      ],
      verify: (_) {
        verify(() => mockMqttService.initializeMqttClient()).called(1);
      },
    );

    test('connectMqtt calls mqttService.connectMqtt', () async {
      when(() => mockMqttService.connectMqtt()).thenAnswer((_) async {});
      when(
        () => mockAnalyticsService.logEvent(name: any<String>(named: 'name')),
      ).thenReturn(null);
      await appCubit.connectMqtt();
      verify(() => mockMqttService.connectMqtt()).called(1);
    });

    test('disconnectMqtt calls mqttService.disconnectMqtt', () {
      when(() => mockMqttService.disconnectMqtt()).thenReturn(null);
      when(
        () => mockAnalyticsService.logEvent(name: any<String>(named: 'name')),
      ).thenReturn(null);
      appCubit.disconnectMqtt();
      verify(() => mockMqttService.disconnectMqtt()).called(1);
    });

    test('reconnectWithNewSettings calls mqttService.reconnectWithNewSettings',
        () async {
      when(() => mockMqttService.reconnectWithNewSettings())
          .thenAnswer((_) async {});
      when(
        () => mockAnalyticsService.logEvent(name: any<String>(named: 'name')),
      ).thenReturn(null);
      await appCubit.reconnectWithNewSettings();
      verify(() => mockMqttService.reconnectWithNewSettings()).called(1);
    });

    blocTest<AppCubit, AppState>(
      'initialize does not save again if values are already set',
      build: () {
        when(() => mockLocalStorageService.getLanguage())
            .thenReturn(const Locale('en', 'US'));
        when(() => mockLocalStorageService.getTheme())
            .thenReturn(ThemeMode.dark);
        when(() => mockLocalStorageService.getBaseColor())
            .thenReturn(Colors.green);
        when(() => mockLocalStorageService.getFontFamily())
            .thenReturn('Poppins');
        return appCubit;
      },
      act: (cubit) => cubit.initialize(),
      expect: () => [
        isA<AppState>()
            .having((s) => s.language, 'language', const Locale('en', 'US'))
            .having((s) => s.theme, 'theme', ThemeMode.dark)
            .having((s) => s.baseColor, 'baseColor', Colors.green)
            .having((s) => s.fontFamily, 'fontFamily', 'Poppins'),
      ],
      verify: (_) {
        verifyNever(
          () => mockLocalStorageService.saveLanguage(
            language: any<Locale>(named: 'language'),
          ),
        );
        verifyNever(
          () => mockLocalStorageService.saveTheme(
            theme: any<ThemeMode>(named: 'theme'),
          ),
        );
        verifyNever(
          () => mockLocalStorageService.saveBaseColor(
            baseColor: any<Color>(named: 'baseColor'),
          ),
        );
        verifyNever(
          () => mockLocalStorageService.saveFontFamily(
            fontFamily: any<String>(named: 'fontFamily'),
          ),
        );
      },
    );

    blocTest<AppCubit, AppState>(
      'initialize saves default font if current font is not supported',
      build: () {
        when(() => mockLocalStorageService.getLanguage())
            .thenReturn(const Locale('en', 'US'));
        when(() => mockLocalStorageService.getTheme())
            .thenReturn(ThemeMode.dark);
        when(() => mockLocalStorageService.getBaseColor())
            .thenReturn(Colors.green);
        when(() => mockLocalStorageService.getFontFamily())
            .thenReturn('UnsupportedFont');
        return appCubit;
      },
      act: (cubit) => cubit.initialize(),
      verify: (_) {
        verify(
          () => mockLocalStorageService.saveFontFamily(
            fontFamily:
                AppVariables.availableFonts[AppVariables.defaultFontFamily] ??
                    AppVariables.defaultFontFamily,
          ),
        ).called(1);
      },
    );
  });
}
