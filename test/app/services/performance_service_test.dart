import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockPerformanceRepository extends Mock implements PerformanceRepository {}

class MockTrace extends Mock implements Trace {}

void main() {
  late PerformanceRepository repository;
  late PerformanceService service;
  late Trace trace;

  setUp(() {
    repository = MockPerformanceRepository();
    service = PerformanceService(performanceRepository: repository);
    trace = MockTrace();
  });

  group('PerformanceService', () {
    test('startTrace calls repository.startTrace', () {
      const name = 'test_trace';

      when(() => repository.startTrace(any<String>())).thenReturn(trace);

      final result = service.startTrace(name);

      verify(() => repository.startTrace(name)).called(1);
      expect(result, equals(trace));
    });

    test('stopTrace calls repository.stopTrace', () {
      service.stopTrace(trace);

      verify(() => repository.stopTrace(trace)).called(1);
    });
  });
}
