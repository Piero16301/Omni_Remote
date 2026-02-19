import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/settings/settings.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  group('SettingsPage', () {
    late MockAppCubit mockAppCubit;

    setUp(() {
      mockAppCubit = MockAppCubit();
      when(() => mockAppCubit.state).thenReturn(const AppState());
    });

    testWidgets('renders SettingsView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<AppCubit>.value(
            value: mockAppCubit,
            child: const SettingsPage(),
          ),
        ),
      );
      expect(find.byType(SettingsView), findsOneWidget);
    });
  });
}
