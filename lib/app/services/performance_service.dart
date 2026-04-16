import 'package:firebase_performance/firebase_performance.dart';
import 'package:omni_remote/app/app.dart';

class PerformanceService {
  PerformanceService({required PerformanceRepository performanceRepository})
      : _performanceRepository = performanceRepository;

  final PerformanceRepository _performanceRepository;

  Trace startTrace(String name) {
    return _performanceRepository.startTrace(name);
  }

  void stopTrace(Trace trace) {
    _performanceRepository.stopTrace(trace);
  }
}
