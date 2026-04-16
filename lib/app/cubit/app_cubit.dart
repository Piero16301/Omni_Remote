import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:omni_remote/app/app.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  final LocalStorageService localStorage = getIt<LocalStorageService>();
  final MqttService mqttService = getIt<MqttService>();
  final CrashService crashService = getIt<CrashService>();
  final AnalyticsService _analyticsService = getIt<AnalyticsService>();

  StreamSubscription<BrokerConnectionStatus>? _connectionStatusSubscription;

  void initialize() {
    // Setting the language to the device language if it's not set
    final language = localStorage.getLanguage();
    if (language == null) {
      final deviceLanguage = AppVariables.supportedLocales.first;
      localStorage.saveLanguage(language: deviceLanguage);
    }

    // Setting the theme to the device theme if it's not set
    final theme = localStorage.getTheme();
    if (theme == null) {
      localStorage.saveTheme(theme: ThemeMode.system);
    }

    // Setting the base color to GREEN if it's not set
    final baseColor = localStorage.getBaseColor();
    if (baseColor == null) {
      localStorage.saveBaseColor(baseColor: AppVariables.defaultBaseColor);
    }

    // Setting the font family to Popping if it's not set
    var fontFamily = localStorage.getFontFamily();
    final isFontSupported = fontFamily != null &&
        AppVariables.availableFonts.containsValue(fontFamily);

    if (!isFontSupported) {
      final defaultFont =
          AppVariables.availableFonts[AppVariables.defaultFontFamily] ??
              AppVariables.defaultFontFamily;
      localStorage.saveFontFamily(fontFamily: defaultFont);
      fontFamily = defaultFont;
    }

    // Add custom keys for CrashService
    crashService
      ..setCustomKey(
        'language',
        localStorage.getLanguage()?.languageCode ??
            AppVariables.supportedLocales.first.languageCode,
      )
      ..setCustomKey(
        'theme',
        localStorage.getTheme()?.name ?? ThemeMode.system.name,
      )
      ..setCustomKey(
        'fontFamily',
        localStorage.getFontFamily() ?? AppVariables.defaultFontFamily,
      );

    // Emit state with all loaded configurations at once
    emit(
      state.copyWith(
        language: localStorage.getLanguage(),
        theme: localStorage.getTheme(),
        baseColor: localStorage.getBaseColor(),
        fontFamily: localStorage.getFontFamily(),
      ),
    );
  }

  Future<void> initializeMqttClient() async {
    _connectionStatusSubscription = mqttService.connectionStatusStream.listen(
      (status) {
        emit(state.copyWith(brokerConnectionStatus: status));
      },
    );
    await mqttService.initializeMqttClient();
  }

  void changeLanguage({required Locale language}) {
    localStorage.saveLanguage(language: language);
    crashService.setCustomKey('language', language.languageCode);
    _analyticsService.logEvent(
      name: 'change_language',
      parameters: {'language': language.languageCode},
    );
    emit(state.copyWith(language: language));
  }

  void changeTheme({required ThemeMode theme}) {
    localStorage.saveTheme(theme: theme);
    crashService.setCustomKey('theme', theme.name);
    _analyticsService.logEvent(
      name: 'change_theme',
      parameters: {'theme': theme.name},
    );
    emit(state.copyWith(theme: theme));
  }

  void changeBaseColor({required Color baseColor}) {
    localStorage.saveBaseColor(baseColor: baseColor);
    _analyticsService.logEvent(
      name: 'change_base_color',
      parameters: {'color_value': ColorHelper.getColorName(baseColor)},
    );
    emit(state.copyWith(baseColor: baseColor));
  }

  void changeFontFamily({required String fontFamily}) {
    localStorage.saveFontFamily(fontFamily: fontFamily);
    crashService.setCustomKey('fontFamily', fontFamily);
    _analyticsService.logEvent(
      name: 'change_font_family',
      parameters: {'font_family': fontFamily},
    );
    emit(state.copyWith(fontFamily: fontFamily));
  }

  Future<void> connectMqtt() async {
    _analyticsService.logEvent(name: 'connect_mqtt');
    await mqttService.connectMqtt();
  }

  void disconnectMqtt() {
    _analyticsService.logEvent(name: 'disconnect_mqtt');
    mqttService.disconnectMqtt();
  }

  Future<void> reconnectWithNewSettings() async {
    _analyticsService.logEvent(name: 'reconnect_mqtt_new_settings');
    await mqttService.reconnectWithNewSettings();
  }

  @override
  Future<void> close() {
    unawaited(_connectionStatusSubscription?.cancel());
    return super.close();
  }
}
