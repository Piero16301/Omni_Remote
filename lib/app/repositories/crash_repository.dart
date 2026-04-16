import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

abstract class CrashRepository {
  void recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? fatal,
  });
  void log(String message);
  void setCustomKey(String key, Object value);
}

class MockCrashRepository implements CrashRepository {
  @override
  void log(String message) {}

  @override
  void recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? fatal,
  }) {}

  @override
  void setCustomKey(String key, Object value) {}
}

class CrashlyticsCrashRepository implements CrashRepository {
  CrashlyticsCrashRepository({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  @override
  void log(String message) {
    unawaited(_crashlytics.log(message));
  }

  @override
  void recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? fatal,
  }) {
    unawaited(
      _crashlytics.recordError(
        exception,
        stack,
        reason: reason,
        information: information,
        fatal: fatal ?? false,
      ),
    );
  }

  @override
  void setCustomKey(String key, Object value) {
    unawaited(_crashlytics.setCustomKey(key, value));
  }
}
