import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/connection/connection.dart';
import 'package:omni_remote/l10n/l10n.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockConnectionCubit extends MockCubit<ConnectionState>
    implements ConnectionCubit {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  group('ConnectionView', () {
    late AppCubit appCubit;
    late ConnectionCubit connectionCubit;

    setUp(() {
      appCubit = MockAppCubit();
      connectionCubit = MockConnectionCubit();

      when(() => appCubit.state).thenReturn(
        const AppState(
          brokerConnectionStatus: BrokerConnectionStatus.connected,
        ),
      );
      when(() => connectionCubit.state).thenReturn(
        ConnectionState(
          formKey: GlobalKey<FormState>(),
          brokerUrl: 'mqtt.eclipse.org',
          brokerPort: '1883',
        ),
      );

      when(() => connectionCubit.togglePasswordVisibility()).thenReturn(null);
      when(() => connectionCubit.saveAndConnect(context: any(named: 'context')))
          .thenAnswer((_) async {});
      when(
        () => connectionCubit.disconnectBroker(context: any(named: 'context')),
      ).thenAnswer((_) async {});
    });

    Widget buildSubject() {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: appCubit),
          BlocProvider.value(value: connectionCubit),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ConnectionView(),
        ),
      );
    }

    testWidgets('triggers cubit methods on form interaction', (tester) async {
      await tester.pumpWidget(buildSubject());

      final urlField = find.widgetWithText(AppTextField, 'mqtt.eclipse.org');
      await tester.enterText(urlField, 'new.url');
      verify(() => connectionCubit.changeBrokerUrl('new.url')).called(1);

      final portField = find.widgetWithText(AppTextField, '1883');
      await tester.enterText(portField, '8883');
      verify(() => connectionCubit.changeBrokerPort('8883')).called(1);

      final typeWidgets = find.byType(AppTextField);
      await tester.enterText(typeWidgets.at(2), 'user');
      verify(() => connectionCubit.changeBrokerUsername('user')).called(1);

      await tester.enterText(typeWidgets.at(3), 'pass');
      verify(() => connectionCubit.changeBrokerPassword('pass')).called(1);
    });

    testWidgets('triggers toggle visibility and validation', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final toggleIcon = find.byWidgetPredicate(
        (widget) =>
            widget is HugeIcon && widget.icon == HugeIcons.strokeRoundedEye,
      );
      final visibilityToggle =
          find.ancestor(of: toggleIcon, matching: find.byType(IconButton));
      tester.widget<IconButton>(visibilityToggle).onPressed?.call();
      verify(() => connectionCubit.togglePasswordVisibility()).called(1);

      final saveButton = find.byType(AppFilledButton);
      tester.widget<AppFilledButton>(saveButton).onPressed?.call();
      verify(
        () => connectionCubit.saveAndConnect(context: any(named: 'context')),
      ).called(1);
    });

    testWidgets('disconnects broker when tapped', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final disconnectBtn = find.byType(AppOutlinedButton);
      tester.widget<AppOutlinedButton>(disconnectBtn).onPressed?.call();
      verify(
        () => connectionCubit.disconnectBroker(context: any(named: 'context')),
      ).called(1);
    });
  });
}
