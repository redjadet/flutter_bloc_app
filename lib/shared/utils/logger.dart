import 'dart:async';
import 'dart:io';

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

  static void error(
    final String message, [
    final Object? error,
    final StackTrace? stackTrace,
  ]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void warning(final String message) {
    _logger.w(message);
  }

  static void info(final String message) {
    _logger.i(message);
  }

  static void debug(final String message) {
    _logger.d(message);
  }

  static T silence<T>(final T Function() action) {
    _silenceDepth++;
    try {
      return action();
    } finally {
      _silenceDepth--;
    }
  }

  static Future<T> silenceAsync<T>(final Future<T> Function() action) async {
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
  bool shouldLog(final LogEvent event) {
    // Check if we're in a test environment
    if (_isTestEnvironment()) {
      return false;
    }

    if (AppLogger._globalSilence || AppLogger._silenceDepth > 0) {
      return false;
    }
    if (kDebugMode) {
      return true;
    }
    return event.level.index >= Level.warning.index;
  }

  /// Detects if we're running in a test environment
  bool _isTestEnvironment() {
    // Check for common test environment indicators
    try {
      // Check if we're running under the test framework
      return Platform.environment.containsKey('FLUTTER_TEST') ||
          Platform.environment.containsKey('DART_TEST_CONFIG') ||
          Zone.current.toString().contains('test');
    } on Exception {
      // If we can't determine, assume not in test
      return false;
    }
  }
}
