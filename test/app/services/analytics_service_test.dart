import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late AnalyticsRepository repository;
  late AnalyticsService service;

  setUp(() {
    repository = MockAnalyticsRepository();
    service = AnalyticsService(analyticsRepository: repository);
  });

  group('AnalyticsService', () {
    test('logEvent calls repository.logEvent', () {
      const name = 'test_event';
      final parameters = {'param': 'value'};

      service.logEvent(name: name, parameters: parameters);

      verify(
        () => repository.logEvent(name: name, parameters: parameters),
      ).called(1);
    });

    test('setCurrentScreen calls repository.setCurrentScreen', () {
      const screenName = 'test_screen';

      service.setCurrentScreen(screenName: screenName);

      verify(
        () => repository.setCurrentScreen(screenName: screenName),
      ).called(1);
    });
  });
}
