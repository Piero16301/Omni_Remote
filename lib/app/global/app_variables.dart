import 'package:flutter/material.dart';

class AppVariables {
  static const String appName = 'Omni Remote';
  static const Color defaultBaseColor = Colors.green;
  static const String defaultFontFamily = 'Poppins';

  static const String lastWillTopic = 'application/lastwill';
  static const String lastWillMessage = 'Client disconnected unexpectedly';

  static const String onlineSuffix = 'online';
  static const String statusSuffix = 'status';
  static const String commandSuffix = 'command';

  static Map<String, String> availableFonts = getAvailableFonts();

  static Map<String, String> getAvailableFonts() {
    return {
      'Merriweather': 'Merriweather',
      'Montserrat': 'Montserrat',
      'Nunito': 'Nunito',
      'Open Sans': 'Open Sans',
      'Orbitron': 'Orbitron',
      'Pacifico': 'Pacifico',
      'Playfair Display': 'Playfair Display',
      'Poppins': 'Poppins',
      'Roboto': 'Roboto',
      'Source Code Pro': 'Source Code Pro',
    };
  }

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('it', 'IT'),
  ];

  static String buildGroupTopic({
    required String groupTitle,
    required String suffix,
  }) {
    final normalizedGroup = _normalizeText(groupTitle);
    return '$normalizedGroup/$suffix';
  }

  static String buildDeviceTopic({
    required String groupTitle,
    required String deviceTitle,
    required String suffix,
  }) {
    final normalizedGroup = _normalizeText(groupTitle);
    final normalizedDevice = _normalizeText(deviceTitle);
    return '$normalizedGroup/$normalizedDevice/$suffix';
  }

  static String _normalizeText(String text) {
    // Convertir a minúsculas
    var normalized = text.toLowerCase();

    // Reemplazar tildes por vocales normales
    normalized = normalized
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');

    // Reemplazar espacios por guiones medios
    normalized = normalized.replaceAll(RegExp(r'\s+'), '-');

    return normalized;
  }
}

enum TopicInfoType {
  group,
  device,
}

enum SnackBarType {
  success,
  error,
  warning,
  info;

  bool get isSuccess => this == SnackBarType.success;
  bool get isError => this == SnackBarType.error;
  bool get isWarning => this == SnackBarType.warning;
  bool get isInfo => this == SnackBarType.info;
}
