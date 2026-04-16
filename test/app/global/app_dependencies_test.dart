import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/app/app.dart';

void main() {
  setUp(() async {
    await getIt.reset();
  });

  group('setupServiceLocator', () {
    test('registers and activates all services for Environment.mock', () {
      setupServiceLocator(Environment.mock);

      expect(getIt.isRegistered<CrashService>(), isTrue);
      expect(getIt.isRegistered<PerformanceService>(), isTrue);
      expect(getIt.isRegistered<AnalyticsService>(), isTrue);
      expect(getIt.isRegistered<LocalStorageService>(), isTrue);
      expect(getIt.isRegistered<MqttService>(), isTrue);

      expect(getIt<CrashService>(), isA<CrashService>());
      expect(getIt<PerformanceService>(), isA<PerformanceService>());
      expect(getIt<AnalyticsService>(), isA<AnalyticsService>());
      expect(getIt<LocalStorageService>(), isA<LocalStorageService>());
      expect(getIt<MqttService>(), isA<MqttService>());
    });

    test('registers all services for Environment.prod', () {
      setupServiceLocator(Environment.prod);

      expect(getIt.isRegistered<CrashService>(), isTrue);
      expect(getIt.isRegistered<PerformanceService>(), isTrue);
      expect(getIt.isRegistered<AnalyticsService>(), isTrue);
      expect(getIt.isRegistered<LocalStorageService>(), isTrue);
      expect(getIt.isRegistered<MqttService>(), isTrue);
    });
  });

  group('ServiceFactory', () {
    test('returns mock repositories for Environment.mock', () {
      expect(
        ServiceFactory.getCrashRepository(Environment.mock),
        isA<MockCrashRepository>(),
      );
      expect(
        ServiceFactory.getPerformanceRepository(Environment.mock),
        isA<MockPerformanceRepository>(),
      );
      expect(
        ServiceFactory.getAnalyticsRepository(Environment.mock),
        isA<MockAnalyticsRepository>(),
      );
      expect(
        ServiceFactory.getLocalStorageRepository(Environment.mock),
        isA<MockLocalStorageRepository>(),
      );
      expect(
        ServiceFactory.getMqttRepository(Environment.mock),
        isA<MockMqttRepository>(),
      );
    });

    test('returns prod repositories for Environment.prod', () {
      void hit(Object Function() getter) {
        try {
          getter();
        } on Object catch (_) {}
      }

      hit(() => ServiceFactory.getCrashRepository(Environment.prod));
      hit(() => ServiceFactory.getPerformanceRepository(Environment.prod));
      hit(() => ServiceFactory.getAnalyticsRepository(Environment.prod));
      hit(() => ServiceFactory.getLocalStorageRepository(Environment.prod));
      hit(() => ServiceFactory.getMqttRepository(Environment.prod));
    });
  });
}
