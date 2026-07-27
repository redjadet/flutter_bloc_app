// Fixture: intentional invalid AppLogger URI interpolation for CI self-test.
void sensitiveLoggingBadUri(Uri uri, Object origin) {
  AppLogger.info('Deep link received: $uri (origin: $origin)');
}

class AppLogger {
  static void info(String message) {}
}
