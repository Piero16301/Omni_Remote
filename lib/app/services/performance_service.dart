import 'package:firebase_performance/firebase_performance.dart';
import 'package:omni_remote/app/app.dart';

class PerformanceService {
  new({required this._performanceRepository});

  final PerformanceRepository _performanceRepository;

  Trace? startTrace(String name) {
    return _performanceRepository.startTrace(name);
  }

  void stopTrace(Trace? trace) {
    if (trace == null) return;
    _performanceRepository.stopTrace(trace);
  }
}
