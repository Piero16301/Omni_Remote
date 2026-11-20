import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:omni_remote/app/app.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  new() : super(const AppState());

  final LocalStorageService _localStorage = getIt<LocalStorageService>();
  final MqttService _mqttService = getIt<MqttService>();
  final CrashService _crashService = getIt<CrashService>();
  final AnalyticsService _analyticsService = getIt<AnalyticsService>();
  final PerformanceService _performanceService = getIt<PerformanceService>();

  StreamSubscription<BrokerConnectionStatus>? _connectionStatusSubscription;

  void initialLoad() {
    final trace = _performanceService.startTrace('app_cubit_initialize');
    try {
      // Setting the language to the device language if it's not set
      final language = _localStorage.getLanguage();
      if (language == null) {
        final deviceLocale = PlatformDispatcher.instance.locale.languageCode;
        final deviceLanguage = ExpressiveLanguages.fromLanguageCode(
          deviceLocale,
        );
        _localStorage.saveLanguage(language: deviceLanguage);
      }

      // Setting the theme to the device theme if it's not set
      final theme = _localStorage.getTheme();
      if (theme == null) {
        _localStorage.saveTheme(theme: ExpressiveTheme.defaultTheme);
      }

      // Setting the base color to default color if it's not set
      final baseColor = _localStorage.getBaseColor();
      if (baseColor == null) {
        _localStorage.saveBaseColor(baseColor: ExpressiveColors.defaultColor);
      }

      // Setting the font family to default font if it's not set
      var fontFamily = _localStorage.getFontFamily();
      final isFontSupported =
          fontFamily != null &&
          ExpressiveFonts.availableFonts.containsValue(fontFamily);

      if (!isFontSupported) {
        const defaultFont = ExpressiveFonts.defaultFont;
        _localStorage.saveFontFamily(fontFamily: defaultFont);
        fontFamily = defaultFont;
      }

      // Setting custom keys and emitting consolidated state
      final resolvedLanguage = _localStorage.getLanguage();
      final resolvedTheme = _localStorage.getTheme();
      final resolvedBaseColor = _localStorage.getBaseColor();

      if (resolvedLanguage != null) {
        _crashService.setCustomKey('language', resolvedLanguage.languageCode);
      }
      if (resolvedTheme != null) {
        _crashService.setCustomKey('theme', resolvedTheme.name);
      }
      if (resolvedBaseColor != null) {
        _crashService.setCustomKey(
          'baseColor',
          ExpressiveColors.toKey(resolvedBaseColor),
        );
      }
      _crashService.setCustomKey('fontFamily', fontFamily);

      emit(
        state.copyWith(
          language: resolvedLanguage,
          theme: resolvedTheme,
          baseColor: resolvedBaseColor,
          fontFamily: fontFamily,
        ),
      );
    } finally {
      _performanceService.stopTrace(trace);
    }
  }

  Future<void> initializeMqttClient() async {
    _connectionStatusSubscription = _mqttService.connectionStatusStream.listen((
      status,
    ) {
      _crashService.setCustomKey('mqtt_status', status.name);
      emit(state.copyWith(brokerConnectionStatus: status));
    });
    await _mqttService.initializeMqttClient();
  }

  void changeLanguage({required Locale language}) {
    _localStorage.saveLanguage(language: language);
    _crashService.setCustomKey('language', language.languageCode);
    _analyticsService.logEvent(
      name: 'change_language',
      parameters: {'language': language.languageCode},
    );
    emit(state.copyWith(language: language));
  }

  void changeTheme({required ThemeMode theme}) {
    _localStorage.saveTheme(theme: theme);
    _crashService.setCustomKey('theme', theme.name);
    _analyticsService.logEvent(
      name: 'change_theme',
      parameters: {'theme': theme.name},
    );
    emit(state.copyWith(theme: theme));
  }

  void changeBaseColor({required Color baseColor}) {
    _localStorage.saveBaseColor(baseColor: baseColor);
    _crashService.setCustomKey('baseColor', ExpressiveColors.toKey(baseColor));
    _analyticsService.logEvent(
      name: 'change_base_color',
      parameters: {'color_value': ExpressiveColors.toKey(baseColor)},
    );
    emit(state.copyWith(baseColor: baseColor));
  }

  void changeFontFamily({required String fontFamily}) {
    _localStorage.saveFontFamily(fontFamily: fontFamily);
    _crashService.setCustomKey('fontFamily', fontFamily);
    _analyticsService.logEvent(
      name: 'change_font_family',
      parameters: {'font_family': fontFamily},
    );
    emit(state.copyWith(fontFamily: fontFamily));
  }

  Future<void> connectMqtt() async {
    _analyticsService.logEvent(name: 'connect_mqtt');
    await _mqttService.connectMqtt();
  }

  void disconnectMqtt() {
    _analyticsService.logEvent(name: 'disconnect_mqtt');
    _mqttService.disconnectMqtt();
  }

  Future<void> reconnectWithNewSettings() async {
    _analyticsService.logEvent(name: 'reconnect_mqtt_new_settings');
    await _mqttService.reconnectWithNewSettings();
  }

  @override
  Future<void> close() {
    unawaited(_connectionStatusSubscription?.cancel());
    return super.close();
  }
}
