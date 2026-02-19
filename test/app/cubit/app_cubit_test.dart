import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockMqttService extends Mock implements MqttService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AppCubit', () {
    late LocalStorageService mockLocalStorageService;
    late MqttService mockMqttService;
    late AppCubit appCubit;

    setUpAll(() {
      registerFallbackValue(const Locale('en', 'US'));
      registerFallbackValue(ThemeMode.system);
    });

    setUp(() {
      mockLocalStorageService = MockLocalStorageService();
      mockMqttService = MockMqttService();

      getIt
        ..registerSingleton<LocalStorageService>(mockLocalStorageService)
        ..registerSingleton<MqttService>(mockMqttService);

      when(() => mockLocalStorageService.getLanguage()).thenReturn(null);
      when(() => mockLocalStorageService.getTheme()).thenReturn(null);
      when(() => mockLocalStorageService.getBaseColor()).thenReturn(null);
      when(() => mockLocalStorageService.getFontFamily()).thenReturn(null);

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
            language: any(named: 'language'),
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
      },
    );
  });
}
