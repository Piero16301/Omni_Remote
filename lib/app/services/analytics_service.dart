import 'package:omni_remote/app/app.dart';

class AnalyticsService {
  AnalyticsService({required this._analyticsRepository});

  final AnalyticsRepository _analyticsRepository;

  void logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    _analyticsRepository.logEvent(name: name, parameters: parameters);
  }

  void setCurrentScreen({required String screenName}) {
    _analyticsRepository.setCurrentScreen(screenName: screenName);
  }
}
