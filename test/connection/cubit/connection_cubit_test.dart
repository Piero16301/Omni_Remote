import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/connection/connection.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockBuildContext extends Mock implements BuildContext {}

class MockAppCubit extends Mock implements AppCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(const Locale('en'));
  });

  group('ConnectionCubit', () {
    late MockLocalStorageService mockLocalStorageService;
    late MockBuildContext mockBuildContext;
    late MockAppCubit mockAppCubit;
    late ConnectionCubit cubit;

    setUp(() async {
      mockLocalStorageService = MockLocalStorageService();
      mockBuildContext = MockBuildContext();
      mockAppCubit = MockAppCubit();

      await getIt.reset();
      setupServiceLocator(Environment.mock);
      getIt
        ..unregister<LocalStorageService>()
        ..registerSingleton<LocalStorageService>(mockLocalStorageService);

      when(() => mockLocalStorageService.getBrokerUrl()).thenReturn('url');
      when(() => mockLocalStorageService.getBrokerPort()).thenReturn('1883');
      when(() => mockLocalStorageService.getBrokerUsername()).thenReturn('usr');
      when(() => mockLocalStorageService.getBrokerPassword()).thenReturn('pwd');

      when(() => mockAppCubit.stream)
          .thenAnswer((_) => const Stream<AppState>.empty());
      when(() => mockAppCubit.state).thenReturn(const AppState());

      when(() => mockBuildContext.read<AppCubit>()).thenReturn(mockAppCubit);

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
            .having((s) => s.brokerUrl, 'brokerUrl', 'url')
            .having((s) => s.brokerPort, 'brokerPort', '1883')
            .having((s) => s.brokerUsername, 'brokerUsername', 'usr')
            .having((s) => s.brokerPassword, 'brokerPassword', 'pwd'),
      ],
    );

    blocTest<ConnectionCubit, ConnectionState>(
      'changeBrokerUrl emits new url',
      build: () => cubit,
      act: (cubit) => cubit.changeBrokerUrl('newUrl'),
      expect: () => [
        isA<ConnectionState>()
            .having((s) => s.brokerUrl, 'brokerUrl', 'newUrl'),
      ],
    );

    blocTest<ConnectionCubit, ConnectionState>(
      'changeBrokerPort emits new port',
      build: () => cubit,
      act: (cubit) => cubit.changeBrokerPort('8883'),
      expect: () => [
        isA<ConnectionState>()
            .having((s) => s.brokerPort, 'brokerPort', '8883'),
      ],
    );

    blocTest<ConnectionCubit, ConnectionState>(
      'changeBrokerUsername emits new username',
      build: () => cubit,
      act: (cubit) => cubit.changeBrokerUsername('admin'),
      expect: () => [
        isA<ConnectionState>()
            .having((s) => s.brokerUsername, 'brokerUsername', 'admin'),
      ],
    );

    blocTest<ConnectionCubit, ConnectionState>(
      'changeBrokerPassword emits new password',
      build: () => cubit,
      act: (cubit) => cubit.changeBrokerPassword('secret'),
      expect: () => [
        isA<ConnectionState>()
            .having((s) => s.brokerPassword, 'brokerPassword', 'secret'),
      ],
    );

    blocTest<ConnectionCubit, ConnectionState>(
      'togglePasswordVisibility toggles boolean',
      build: () => cubit,
      act: (cubit) => cubit.togglePasswordVisibility(),
      expect: () => [
        isA<ConnectionState>()
            .having((s) => s.hidePassword, 'hidePassword', isFalse),
      ],
    );

    testWidgets('saveAndConnect returns early when form is not valid',
        (tester) async {
      final customCubit = ConnectionCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: customCubit.state.formKey,
              child: TextFormField(
                validator: (_) => 'Error',
              ),
            ),
          ),
        ),
      );

      final context = tester.element(find.byType(Form));
      await customCubit.saveAndConnect(context: context);

      verifyNever(
        () => mockLocalStorageService.saveBrokerUrl(
          brokerUrl: any(named: 'brokerUrl'),
        ),
      );
      verifyNever(() => mockAppCubit.reconnectWithNewSettings());

      await customCubit.close();
    });

    testWidgets(
        'saveAndConnect saves to local storage and reconnects on valid form '
        'widget', (tester) async {
      cubit
        ..changeBrokerUrl('myBroker')
        ..changeBrokerPort('1884')
        ..changeBrokerUsername('myUser')
        ..changeBrokerPassword('myPass');

      final formKey = cubit.state.formKey;

      when(
        () => mockLocalStorageService.saveBrokerUrl(
          brokerUrl: any(named: 'brokerUrl'),
        ),
      ).thenReturn(null);
      when(
        () => mockLocalStorageService.saveBrokerPort(
          brokerPort: any(named: 'brokerPort'),
        ),
      ).thenReturn(null);
      when(
        () => mockLocalStorageService.saveBrokerUsername(
          brokerUsername: any(named: 'brokerUsername'),
        ),
      ).thenReturn(null);
      when(
        () => mockLocalStorageService.saveBrokerPassword(
          brokerPassword: any(named: 'brokerPassword'),
        ),
      ).thenReturn(null);
      when(() => mockAppCubit.reconnectWithNewSettings())
          .thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AppCubit>.value(
            value: mockAppCubit,
            child: Scaffold(
              body: Form(
                key: formKey,
                child: TextFormField(
                  validator: (_) => null,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Form));

      await cubit.saveAndConnect(context: context);

      verify(() => mockLocalStorageService.saveBrokerUrl(brokerUrl: 'myBroker'))
          .called(1);
      verify(() => mockLocalStorageService.saveBrokerPort(brokerPort: '1884'))
          .called(1);
      verify(
        () => mockLocalStorageService.saveBrokerUsername(
          brokerUsername: 'myUser',
        ),
      ).called(1);
      verify(
        () => mockLocalStorageService.saveBrokerPassword(
          brokerPassword: 'myPass',
        ),
      ).called(1);
      verify(() => mockAppCubit.reconnectWithNewSettings()).called(1);
    });

    testWidgets('disconnectBroker calls AppCubit.disconnectMqtt',
        (tester) async {
      when(() => mockAppCubit.disconnectMqtt()).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AppCubit>.value(
            value: mockAppCubit,
            child: const Scaffold(
              body: SizedBox(),
            ),
          ),
        ),
      );

      final context = tester.element(find.byType(SizedBox));
      cubit.disconnectBroker(context: context);

      verify(() => mockAppCubit.disconnectMqtt()).called(1);
    });
  });
}
