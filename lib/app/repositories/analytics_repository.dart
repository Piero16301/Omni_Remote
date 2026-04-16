import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';

abstract class AnalyticsRepository {
  void logEvent({
    required String name,
    Map<String, Object>? parameters,
  });
  void setCurrentScreen({required String screenName});
}

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  void logEvent({required String name, Map<String, Object>? parameters}) {}

  @override
  void setCurrentScreen({required String screenName}) {}
}

class FirebaseAnalyticsRepository implements AnalyticsRepository {
  FirebaseAnalyticsRepository({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  void logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
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
