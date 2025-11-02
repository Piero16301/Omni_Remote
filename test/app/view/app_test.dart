import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:omni_remote/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_api_remote/user_api_remote.dart';
import 'package:user_repository/user_repository.dart';

import 'app_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  group('App with SharedPreferences', () {
    late MockSharedPreferences mockPreferences;

    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      mockPreferences = MockSharedPreferences();
    });

    testWidgets('renders AppPage with mocked SharedPreferences', (
      tester,
    ) async {
      when(mockPreferences.getString(any)).thenReturn('mock_value');
      when(mockPreferences.getBool(any)).thenReturn(true);
      when(mockPreferences.getStringList(any)).thenReturn(['mock_league']);
      final userApi = UserApiRemote(preferences: mockPreferences);
      final userRepository = UserRepository(userApi: userApi);

      await tester.pumpWidget(
        MaterialApp(
          home: AppPage(userRepository: userRepository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppPage), findsOneWidget);
    });

    testWidgets(
      'renders AppPage with mocked SharedPreferences and no leagues',
      (tester) async {
        when(mockPreferences.getString(any)).thenReturn('mock_value');
        when(mockPreferences.getBool(any)).thenReturn(true);
        when(mockPreferences.getStringList(any)).thenReturn(null);
        final userApi = UserApiRemote(preferences: mockPreferences);
        final userRepository = UserRepository(userApi: userApi);

        await tester.pumpWidget(
          MaterialApp(
            home: AppPage(userRepository: userRepository),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppPage), findsOneWidget);
      },
    );

    testWidgets(
      'renders AppPage with mocked SharedPreferences and empty leagues',
      (tester) async {
        when(mockPreferences.getString(any)).thenReturn('mock_value');
        when(mockPreferences.getBool(any)).thenReturn(true);
        when(mockPreferences.getStringList(any)).thenReturn([]);
        final userApi = UserApiRemote(preferences: mockPreferences);
        final userRepository = UserRepository(userApi: userApi);

        await tester.pumpWidget(
          MaterialApp(
            home: AppPage(userRepository: userRepository),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppPage), findsOneWidget);
      },
    );
  });
}
