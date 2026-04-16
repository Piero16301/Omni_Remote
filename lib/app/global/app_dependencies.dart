import 'package:get_it/get_it.dart';
import 'package:omni_remote/app/app.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator(Environment env) {
  getIt
    // 1. Infraestructura y Telemetría (Base de todo)
    ..registerLazySingleton<CrashService>(
      () => CrashService(
        crashRepository: ServiceFactory.getCrashRepository(env),
      ),
    )
    ..registerLazySingleton<PerformanceService>(
      () => PerformanceService(
        performanceRepository: ServiceFactory.getPerformanceRepository(env),
      ),
    )
    ..registerLazySingleton<AnalyticsService>(
      () => AnalyticsService(
        analyticsRepository: ServiceFactory.getAnalyticsRepository(env),
      ),
    )

    // 2. Configuración y Almacenamiento Local
    ..registerLazySingleton<LocalStorageService>(
      () => LocalStorageService(
        localStorageRepository: ServiceFactory.getLocalStorageRepository(env),
      ),
    )

    // 3. Conectividad de red
    ..registerLazySingleton<MqttService>(
      () => MqttService(
        mqttRepository: ServiceFactory.getMqttRepository(env),
      ),
    );
}

enum Environment { mock, prod }

class ServiceFactory {
  static CrashRepository getCrashRepository(Environment env) {
    switch (env) {
      case Environment.mock:
        return MockCrashRepository();
      case Environment.prod:
        return CrashlyticsCrashRepository();
    }
  }

  static PerformanceRepository getPerformanceRepository(Environment env) {
    switch (env) {
      case Environment.mock:
        return MockPerformanceRepository();
      case Environment.prod:
        return FirebasePerformanceRepository();
    }
  }

  static AnalyticsRepository getAnalyticsRepository(Environment env) {
    switch (env) {
      case Environment.mock:
        return MockAnalyticsRepository();
      case Environment.prod:
        return FirebaseAnalyticsRepository();
    }
  }

  static LocalStorageRepository getLocalStorageRepository(Environment env) {
    switch (env) {
      case Environment.mock:
        return MockLocalStorageRepository();
      case Environment.prod:
        return HiveLocalStorageRepository();
    }
  }

  static MqttRepository getMqttRepository(Environment env) {
    switch (env) {
      case Environment.mock:
        return MockMqttRepository();
      case Environment.prod:
        return ServerMqttRepository();
    }
  }
}
