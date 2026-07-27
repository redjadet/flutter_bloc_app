// Fixture: Bearer credential in log message (forbidden).
void sensitiveLoggingBadBearer() {
  AppLogger.debug('Authorization Bearer abc.def.ghi');
}

class AppLogger {
  static void debug(String message) {}
}
