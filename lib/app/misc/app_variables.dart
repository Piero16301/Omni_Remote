class AppVariables {
  static const String appName = 'Omni Remote';
  static const String defaultBaseColor = 'INDIGO';

  static const String onlineSuffix = 'online';
  static const String statusSuffix = 'status';
  static const String commandSuffix = 'command';

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
