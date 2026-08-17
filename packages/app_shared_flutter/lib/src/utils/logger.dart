import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../platform/platform_environment.dart';
import 'log_redaction.dart';

enum AppLogLevel { debug, info, warning, error }

@immutable
class AppLogEntry {
  const AppLogEntry({
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });

  final AppLogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
}

/// App-level logging utility shared across packages.
///
/// All public entry points sanitize message and error via [LogRedaction]
/// before observer / console sinks.
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
  static void Function(AppLogEntry entry)? _observer;

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(AppLogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message) {
    _log(AppLogLevel.warning, message);
  }

  static void info(String message) {
    _log(AppLogLevel.info, message);
  }

  static void debug(String message) {
    _log(AppLogLevel.debug, message);
  }

  /// Logs [message] at debug level only in debug mode (avoids work in release).
  static void debugInDebugMode(String message) {
    if (kDebugMode) {
      _log(AppLogLevel.debug, message, notifyObserver: false);
    }
  }

  /// Structured event log: `event key=value…` from redacted [fields].
  static void event(
    AppLogLevel level,
    String event, {
    Map<String, Object?> fields = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    final safeEvent = LogRedaction.sanitizeMessage(event);
    final safe = LogRedaction.safeFields(fields);
    final buffer = StringBuffer(safeEvent);
    for (final entry in safe.entries) {
      buffer.write(' ');
      buffer.write(entry.key);
      buffer.write('=');
      buffer.write(_formatFieldValue(entry.value));
    }
    _log(level, buffer.toString(), error: error, stackTrace: stackTrace);
  }

  /// Returns a stream error handler that logs with [logContext] and swallows.
  static void Function(Object error, StackTrace stackTrace) streamErrorHandler(
    String logContext,
  ) =>
      (err, stackTrace) =>
          AppLogger.error('$logContext failed', err, stackTrace);

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

  @visibleForTesting
  static void Function(AppLogEntry entry)? get observer => _observer;

  @visibleForTesting
  static set observer(void Function(AppLogEntry entry)? observer) {
    _observer = observer;
  }

  static void silenceGlobally() {
    _globalSilence = true;
  }

  static void restoreGlobalLogging() {
    _globalSilence = false;
  }

  static void _log(
    AppLogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool notifyObserver = true,
  }) {
    final safeMessage = LogRedaction.sanitizeMessage(message);
    final safeError = LogRedaction.sanitizeError(error);
    if (notifyObserver) {
      _notifyObserver(
        AppLogEntry(
          level: level,
          message: safeMessage,
          error: safeError,
          stackTrace: stackTrace,
        ),
      );
    }
    switch (level) {
      case AppLogLevel.debug:
        _logger.d(safeMessage, error: safeError, stackTrace: stackTrace);
      case AppLogLevel.info:
        _logger.i(safeMessage, error: safeError, stackTrace: stackTrace);
      case AppLogLevel.warning:
        _logger.w(safeMessage, error: safeError, stackTrace: stackTrace);
      case AppLogLevel.error:
        _logger.e(safeMessage, error: safeError, stackTrace: stackTrace);
    }
  }

  static String _formatFieldValue(Object? value) {
    if (value == null) {
      return 'null';
    }
    if (value is Map) {
      final parts = <String>[];
      for (final entry in value.entries) {
        parts.add('${entry.key}:${_formatFieldValue(entry.value)}');
      }
      return '{${parts.join(',')}}';
    }
    return value.toString();
  }

  static void _notifyObserver(AppLogEntry entry) {
    _observer?.call(entry);
  }
}

class _DebugOnlyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
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

  bool _isTestEnvironment() {
    try {
      final env = platformEnvironment();
      return env.containsKey('FLUTTER_TEST') ||
          env.containsKey('DART_TEST_CONFIG') ||
          Zone.current.toString().contains('test');
    } on Exception {
      return false;
    }
  }
}
