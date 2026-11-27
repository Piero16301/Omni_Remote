import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';

abstract class AnalyticsRepository {
  void logEvent({required String name, Map<String, Object>? parameters});
  void setCurrentScreen({required String screenName});
}

class MockAnalyticsRepository implements AnalyticsRepository {
  final List<({String name, Map<String, Object>? parameters})> loggedEvents =
      <({String name, Map<String, Object>? parameters})>[];
  final List<String> screenHistory = <String>[];

  @override
  void logEvent({required String name, Map<String, Object>? parameters}) {
    loggedEvents.add((name: name, parameters: parameters));
    developer.log('[MockAnalytics] event=$name params=$parameters');
  }

  @override
  void setCurrentScreen({required String screenName}) {
    screenHistory.add(screenName);
    logEvent(name: 'screen_view', parameters: {'screen_name': screenName});
  }
}

class FirebaseAnalyticsRepository implements AnalyticsRepository {
  new({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  void logEvent({required String name, Map<String, Object>? parameters}) {
    unawaited(_analytics.logEvent(name: name, parameters: parameters));
  }

  @override
  void setCurrentScreen({required String screenName}) {
    unawaited(
      _analytics.logEvent(
        name: 'screen_view',
        parameters: {'screen_name': screenName},
      ),
    );
  }
}
