import 'package:bloc_test/bloc_test.dart';
import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart' hide ConnectionState;
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/connection/connection.dart';
import 'package:omni_remote/l10n/l10n.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit;

class MockConnectionCubit extends MockCubit<ConnectionState>
    implements ConnectionCubit;

class FakeBuildContext extends Fake implements BuildContext;

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

      final urlField = find.widgetWithText(
        ExpressiveTextFormField,
        'mqtt.eclipse.org',
      );
      await tester.enterText(urlField, 'new.url');
      verify(() => connectionCubit.changeBrokerUrl('new.url')).called(1);

      final portField = find.widgetWithText(ExpressiveTextFormField, '1883');
      await tester.enterText(portField, '8883');
      verify(() => connectionCubit.changeBrokerPort('8883')).called(1);

      final typeWidgets = find.byType(ExpressiveTextFormField);
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
            widget is HugeIcon && widget.icon == HugeIcons.strokeRoundedView,
      );
      expect(toggleIcon, findsOneWidget);
      await tester.tap(toggleIcon);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is HugeIcon &&
              widget.icon == HugeIcons.strokeRoundedViewOffSlash,
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).at(3)).obscureText,
        isFalse,
      );

      final saveButton = find.byWidgetPredicate(
        (w) =>
            w is ExpressiveButton &&
            w.variant == ExpressiveButtonVariant.filled,
      );
      tester.widget<ExpressiveButton>(saveButton).onPressed?.call();
      verify(
        () => connectionCubit.saveAndConnect(context: any(named: 'context')),
      ).called(1);
    });

    testWidgets('disconnects broker when tapped', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final disconnectBtn = find.byWidgetPredicate(
        (w) =>
            w is ExpressiveButton &&
            w.variant == ExpressiveButtonVariant.outlined,
      );
      tester.widget<ExpressiveButton>(disconnectBtn).onPressed?.call();
      verify(
        () => connectionCubit.disconnectBroker(context: any(named: 'context')),
      ).called(1);
    });
  });
}
