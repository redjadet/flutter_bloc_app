import 'package:flutter/foundation.dart';

/// Simple logging utility for the app
class AppLogger {
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final buffer = StringBuffer(message);
      if (error != null) {
        buffer.write('\nError: $error');
      }
      if (stackTrace != null) {
        buffer.write('\nStackTrace: $stackTrace');
      }
      debugPrint(buffer.toString());
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('WARNING: $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('INFO: $message');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('DEBUG: $message');
    }
  }
}
