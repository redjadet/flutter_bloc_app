// Fixture: check-ignore without reason must fail self-test.
void sensitiveLoggingBadIgnore(dynamic response) {
  // check-ignore
  AppLogger.error('demo', response.body);
}

class AppLogger {
  static void error(String message, [Object? error]) {}
}
