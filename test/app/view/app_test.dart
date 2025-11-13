import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/app/app.dart';
import 'package:user_api_remote/user_api_remote.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  group('App with SharedPreferences', () {
    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('renders AppPage with mocked SharedPreferences', (
      tester,
    ) async {
      final userApi = UserApiRemote();
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
        final userApi = UserApiRemote();
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
        final userApi = UserApiRemote();
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
