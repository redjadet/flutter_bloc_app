import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Simple logging utility for the app
class AppLogger {
  static final Logger _logger = Logger(
    filter: _DebugOnlyFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: false,
      printEmojis: false,
      noBoxingByDefault: true,
    ),
  );

  static int _silenceDepth = 0;
  static bool _globalSilence = false;

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void debug(String message) {
    _logger.d(message);
  }

  static T silence<T>(T Function() action) {
    _silenceDepth++;
    try {
      return action();
    } finally {
      _silenceDepth--;
    }
  }

  static Future<T> silenceAsync<T>(Future<T> Function() action) async {
    _silenceDepth++;
    try {
      return await action();
    } finally {
      _silenceDepth--;
    }
  }

  static bool get isSilenced => _silenceDepth > 0;

  static void silenceGlobally() {
    _globalSilence = true;
  }

  static void restoreGlobalLogging() {
    _globalSilence = false;
  }
}

class _DebugOnlyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (AppLogger._globalSilence || AppLogger._silenceDepth > 0) {
      return false;
    }
    if (kDebugMode) {
      return true;
    }
    return event.level.index >= Level.warning.index;
  }
}
