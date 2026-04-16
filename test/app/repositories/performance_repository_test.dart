import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockFirebasePerformance extends Mock implements FirebasePerformance {}

class MockTrace extends Mock implements Trace {}

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
}
