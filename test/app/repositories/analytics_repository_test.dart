import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  late FirebaseAnalytics analytics;
  late FirebaseAnalyticsRepository repository;

  setUp(() {
    analytics = MockFirebaseAnalytics();
    repository = FirebaseAnalyticsRepository(analytics: analytics);
  });

  group('FirebaseAnalyticsRepository', () {
    test('logEvent calls analytics.logEvent', () async {
      const name = 'test_event';
      final parameters = {'param': 'value'};

      when(
        () => analytics.logEvent(
          name: any<String>(named: 'name'),
          parameters: any<Map<String, Object>?>(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      repository.logEvent(name: name, parameters: parameters);

      verify(
        () => analytics.logEvent(name: name, parameters: parameters),
      ).called(1);
    });

    test('setCurrentScreen calls analytics.logEvent with screen_view',
        () async {
      const screenName = 'test_screen';

      when(
        () => analytics.logEvent(
          name: any<String>(named: 'name'),
          parameters: any<Map<String, Object>?>(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      repository.setCurrentScreen(screenName: screenName);

      verify(
        () => analytics.logEvent(
          name: 'screen_view',
          parameters: {'screen_name': screenName},
        ),
      ).called(1);
    });
  });
}
