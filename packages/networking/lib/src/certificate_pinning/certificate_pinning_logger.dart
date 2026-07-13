import 'dart:collection';

import 'package:app_shared_flutter/app_shared_flutter.dart';

import 'certificate_pin_result.dart';
import 'certificate_pinning_mode.dart';

/// Structured security log entry for developers (safe fields only).
final class CertificatePinningLogEntry {
  const CertificatePinningLogEntry({
    required this.timestamp,
    required this.host,
    required this.mode,
    required this.success,
    required this.elapsed,
    this.matchKind,
    this.failureType,
    this.message,
  });

  final DateTime timestamp;
  final String host;
  final CertificatePinningMode mode;
  final bool success;
  final Duration elapsed;
  final CertificatePinMatchKind? matchKind;
  final String? failureType;
  final String? message;

  String get displayLine {
    final String result = success
        ? 'ok${matchKind == null ? '' : ' (${matchKind!.name})'}'
        : 'fail${failureType == null ? '' : ' ($failureType)'}';
    return '${timestamp.toIso8601String()} host=$host mode=${mode.name} '
        'result=$result elapsedMs=${elapsed.inMilliseconds}'
        '${message == null ? '' : ' msg=$message'}';
  }
}

/// Developer-facing pinning logger with an in-memory ring buffer.
final class CertificatePinningLogger {
  CertificatePinningLogger({
    this.enableVerboseLogging = false,
    this.maxEntries = 50,
  });

  final bool enableVerboseLogging;
  final int maxEntries;
  final ListQueue<CertificatePinningLogEntry> _entries =
      ListQueue<CertificatePinningLogEntry>();

  List<CertificatePinningLogEntry> get entries =>
      List<CertificatePinningLogEntry>.unmodifiable(_entries);

  void clear() => _entries.clear();

  void logValidation({
    required final String host,
    required final CertificatePinningMode mode,
    required final CertificatePinResult result,
    required final Duration elapsed,
  }) {
    final bool success = result is CertificatePinSuccess;
    final CertificatePinMatchKind? matchKind = switch (result) {
      CertificatePinSuccess(:final matchKind) => matchKind,
      CertificatePinFailureResult() => null,
    };
    final String? failureType = switch (result) {
      CertificatePinFailureResult(:final failure) =>
        failure.runtimeType.toString(),
      CertificatePinSuccess() => null,
    };

    final CertificatePinningLogEntry entry = CertificatePinningLogEntry(
      timestamp: DateTime.now().toUtc(),
      host: host,
      mode: mode,
      success: success,
      elapsed: elapsed,
      matchKind: matchKind,
      failureType: failureType,
    );
    _entries.addLast(entry);
    while (_entries.length > maxEntries) {
      _entries.removeFirst();
    }

    final String message = entry.displayLine;
    if (success) {
      AppLogger.info('cert_pin|$message');
    } else {
      AppLogger.warning('cert_pin|$message');
    }

    if (enableVerboseLogging && result is CertificatePinFailureResult) {
      final Object? cause = result.failure.cause;
      if (cause != null) {
        AppLogger.debug('cert_pin|cause=$cause');
      }
    }
  }
}
