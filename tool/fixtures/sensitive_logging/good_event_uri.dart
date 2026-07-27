// Fixture: safe event logging without raw URI interpolation.
void sensitiveLoggingGoodEventUri(Uri uri) {
  AppLogger.event(
    AppLogLevel.info,
    'deeplink.received',
    fields: {'scheme': uri.scheme, 'host': uri.host, 'path': uri.path},
  );
}

enum AppLogLevel { info }

class AppLogger {
  static void event(
    AppLogLevel level,
    String event, {
    Map<String, Object?> fields = const {},
  }) {}
}
