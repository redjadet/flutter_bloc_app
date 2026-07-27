// Fixture: safe debug message without Bearer credentials.
void sensitiveLoggingGoodRedacted() {
  AppLogger.debug('auth challenge failed statusCode=401');
}

class AppLogger {
  static void debug(String message) {}
}
