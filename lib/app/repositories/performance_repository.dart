import 'dart:async';

import 'package:firebase_performance/firebase_performance.dart';

abstract class PerformanceRepository {
  Trace startTrace(String name);
  void stopTrace(Trace trace);
}

class MockPerformanceRepository implements PerformanceRepository {
  @override
  Trace startTrace(String name) {
    throw UnimplementedError();
  }

  @override
  void stopTrace(Trace trace) {
    throw UnimplementedError();
  }
}

class FirebasePerformanceRepository implements PerformanceRepository {
  FirebasePerformanceRepository({FirebasePerformance? performance})
      : _performance = performance ?? FirebasePerformance.instance;

  final FirebasePerformance _performance;

  @override
  Trace startTrace(String name) {
    final trace = _performance.newTrace(name);
    unawaited(trace.start());
    return trace;
  }

  @override
  void stopTrace(Trace trace) {
    unawaited(trace.stop());
  }
}
