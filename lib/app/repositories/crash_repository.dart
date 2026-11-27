import 'dart:async';
import 'dart:developer' as developer;

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
  final List<String> logs = <String>[];
  final Map<String, Object> customKeys = <String, Object>{
    'environment': 'mock',
  };
  final List<Object> recordedErrors = <Object>[];

  @override
  void log(String message) {
    logs.add(message);
    developer.log('[MockCrash] $message');
  }

  @override
  void recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? fatal,
  }) {
    recordedErrors.add(exception as Object);
    developer.log(
      '[MockCrash] Error: $exception '
      '(reason: $reason, fatal: ${fatal ?? false})',
      error: exception,
      stackTrace: stack,
    );
  }

  @override
  void setCustomKey(String key, Object value) {
    customKeys[key] = value;
  }
}

class CrashlyticsCrashRepository implements CrashRepository {
  new({FirebaseCrashlytics? crashlytics})
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
