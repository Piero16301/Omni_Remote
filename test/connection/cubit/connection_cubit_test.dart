import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/connection/connection.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ConnectionCubit', () {
    late LocalStorageService mockLocalStorageService;
    late ConnectionCubit cubit;

    setUp(() {
      mockLocalStorageService = MockLocalStorageService();
      getIt.registerSingleton<LocalStorageService>(mockLocalStorageService);

      when(() => mockLocalStorageService.getBrokerUrl()).thenReturn('url');
      when(() => mockLocalStorageService.getBrokerPort()).thenReturn('1883');
      when(() => mockLocalStorageService.getBrokerUsername()).thenReturn('usr');
      when(() => mockLocalStorageService.getBrokerPassword()).thenReturn('pwd');

      cubit = ConnectionCubit();
    });

    tearDown(() {
      unawaited(cubit.close());
      unawaited(getIt.reset());
    });

    test('initial state is correct', () {
      expect(cubit.state.brokerUrl, isEmpty);
      expect(cubit.state.hidePassword, isTrue);
    });

    blocTest<ConnectionCubit, ConnectionState>(
      'loadSettings emits correct values',
      build: () => cubit,
      act: (cubit) => cubit.loadSettings(),
      expect: () => [
        isA<ConnectionState>()
            .having((s) => s.brokerUrl, 'url', 'url')
            .having((s) => s.brokerPort, 'port', '1883')
            .having((s) => s.brokerUsername, 'user', 'usr')
            .having((s) => s.brokerPassword, 'pass', 'pwd'),
      ],
    );

    blocTest<ConnectionCubit, ConnectionState>(
      'changeBrokerUrl emits new url',
      build: () => cubit,
      act: (cubit) => cubit.changeBrokerUrl('newUrl'),
      expect: () => [
        isA<ConnectionState>().having((s) => s.brokerUrl, 'url', 'newUrl'),
      ],
    );

    blocTest<ConnectionCubit, ConnectionState>(
      'togglePasswordVisibility toggles boolean',
      build: () => cubit,
      act: (cubit) => cubit.togglePasswordVisibility(),
      expect: () => [
        isA<ConnectionState>().having((s) => s.hidePassword, 'hidden', isFalse),
      ],
    );
  });
}
