import 'package:omni_remote/app/app.dart';

class CrashService {
  CrashService({required CrashRepository crashRepository})
      : _crashRepository = crashRepository;

  final CrashRepository _crashRepository;

  void recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? fatal,
  }) {
    _crashRepository.recordError(
      exception,
      stack,
      reason: reason,
      information: information,
      fatal: fatal ?? false,
    );
  }

  void log(String message) {
    _crashRepository.log(message);
  }

  void setCustomKey(String key, Object value) {
    _crashRepository.setCustomKey(key, value);
  }
}
