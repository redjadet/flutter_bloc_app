// Fixture: justified ignore for body logging.
void sensitiveLoggingIgnoredBody(dynamic response) {
  // check-ignore: intentional fixture demonstrating justified ignore
  AppLogger.error('demo', response.body);
}

class AppLogger {
  static void error(String message, [Object? error]) {}
}
