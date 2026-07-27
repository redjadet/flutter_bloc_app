// Fixture: status-only logging without body.
void sensitiveLoggingGoodStatus(dynamic response) {
  AppLogger.event(
    AppLogLevel.error,
    'http.request',
    fields: {'statusCode': response.statusCode},
  );
}

enum AppLogLevel { error }

class AppLogger {
  static void event(
    AppLogLevel level,
    String event, {
    Map<String, Object?> fields = const {},
  }) {}
}
