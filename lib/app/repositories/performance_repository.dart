import 'dart:async';

import 'package:firebase_performance/firebase_performance.dart';

abstract class PerformanceRepository {
  Trace? startTrace(String name);
  void stopTrace(Trace? trace);
}

class MockPerformanceRepository implements PerformanceRepository {
  final List<String> startedTraces = <String>[];

  @override
  Trace? startTrace(String name) {
    startedTraces.add(name);
    return null;
  }

  @override
  void stopTrace(Trace? trace) {}
}

class NoopPerformanceRepository implements PerformanceRepository {
  @override
  Trace? startTrace(String name) => null;

  @override
  void stopTrace(Trace? trace) {}
}

class FirebasePerformanceRepository implements PerformanceRepository {
  new({FirebasePerformance? performance})
    : _performance = performance ?? FirebasePerformance.instance;

  final FirebasePerformance _performance;

  @override
  Trace startTrace(String name) {
    final trace = _performance.newTrace(name);
    unawaited(trace.start().catchError((Object _) {}));
    return trace;
  }

  @override
  void stopTrace(Trace? trace) {
    if (trace == null) return;
    unawaited(trace.stop().catchError((Object _) {}));
  }
}
