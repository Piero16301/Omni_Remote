import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockFirebasePerformance extends Mock implements FirebasePerformance;

class MockTrace extends Mock implements Trace;

void main() {
  late FirebasePerformance performance;
  late FirebasePerformanceRepository repository;
  late Trace trace;

  setUp(() {
    performance = MockFirebasePerformance();
    repository = FirebasePerformanceRepository(performance: performance);
    trace = MockTrace();
  });

  group('FirebasePerformanceRepository', () {
    test('startTrace calls performance.newTrace and starts it', () async {
      const name = 'test_trace';

      when(() => performance.newTrace(any<String>())).thenReturn(trace);
      when(() => trace.start()).thenAnswer((_) async {});

      final result = repository.startTrace(name);

      verify(() => performance.newTrace(name)).called(1);
      verify(() => trace.start()).called(1);
      expect(result, equals(trace));
    });

    test('stopTrace calls trace.stop', () async {
      when(() => trace.stop()).thenAnswer((_) async {});

      repository.stopTrace(trace);

      verify(() => trace.stop()).called(1);
    });
  });

  group('NoopPerformanceRepository', () {
    test('startTrace returns null and stopTrace is a no-op', () {
      final noop = NoopPerformanceRepository();
      final result = noop.startTrace('trace_name');
      expect(result, isNull);
      expect(() => noop.stopTrace(result), returnsNormally);
    });
  });

  group('MockPerformanceRepository', () {
    test('startTrace records trace name and returns null', () {
      final mock = MockPerformanceRepository();
      final result = mock.startTrace('trace_name');
      expect(result, isNull);
      expect(mock.startedTraces, contains('trace_name'));
    });

    test('stopTrace completes normally', () {
      final mock = MockPerformanceRepository();
      expect(() => mock.stopTrace(MockTrace()), returnsNormally);
      expect(() => mock.stopTrace(null), returnsNormally);
    });
  });
}
