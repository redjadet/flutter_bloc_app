// Fixture: logging response.body (forbidden).
void sensitiveLoggingBadBody(dynamic response) {
  AppLogger.error('failed', response.body);
}

class AppLogger {
  static void error(String message, [Object? error]) {}
}
