import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/bootstrap/app_version_service.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/config/flavor.dart';

/// Crashlytics allowlisted keys + handlers for production-readiness demos.
class FirebaseCrashlyticsBootstrap {
  /// Injectable Crashlytics sink for tests (sanitized exception text only).
  @visibleForTesting
  static Future<void> Function(
    Object exception,
    StackTrace? stack, {
    required bool fatal,
    required String reason,
  })
  recordCrash = _defaultRecordCrash;

  /// Injectable custom-key writer (tests avoid real Crashlytics).
  @visibleForTesting
  static void Function(String key, Object value) setCustomKey =
      _defaultSetCustomKey;

  static Future<void> _defaultRecordCrash(
    Object exception,
    StackTrace? stack, {
    required bool fatal,
    required String reason,
  }) {
    return FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      reason: reason,
      printDetails: false,
      fatal: fatal,
    );
  }

  static void _defaultSetCustomKey(String key, Object value) {
    if (!FirebaseBootstrapService.isFirebaseInitialized) {
      return;
    }
    unawaited(FirebaseCrashlytics.instance.setCustomKey(key, value));
  }

  /// Allowlisted Crashlytics metadata only (no PII / tokens / device IDs).
  @visibleForTesting
  static Map<String, String> metadataKeys({
    String? flavorName,
    String? appVersion,
    bool? firebaseReady,
  }) {
    return <String, String>{
      'flavor': flavorName ?? FlavorManager.I.name,
      'app_version': appVersion ?? AppVersionService.getAppVersion(),
      'firebase_ready':
          (firebaseReady ?? FirebaseBootstrapService.isFirebaseInitialized)
              .toString(),
    };
  }

  /// Register global crash reporting handlers.
  static void registerHandlers() {
    final Map<String, String> metadata = metadataKeys();
    for (final MapEntry<String, String> entry in metadata.entries) {
      setCustomKey(entry.key, entry.value);
    }

    final previousFlutterHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      final Object? sanitized = LogRedaction.sanitizeError(details.exception);
      unawaited(
        recordCrash(
          sanitized ?? 'flutter_fatal',
          details.stack,
          fatal: true,
          reason: 'flutter_fatal',
        ),
      );
      previousFlutterHandler?.call(details);
    };

    final previousPlatformHandler = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      final Object? sanitized = LogRedaction.sanitizeError(error);
      unawaited(
        recordCrash(
          sanitized ?? 'platform_fatal',
          stackTrace,
          fatal: true,
          reason: 'platform_fatal',
        ),
      );
      return previousPlatformHandler?.call(error, stackTrace) ?? true;
    };
  }

  /// Production-readiness demo: emit a sanitized non-fatal (no PII).
  ///
  /// Signature matches the production-readiness cubit non-fatal sink so the
  /// router can pass this method as a tear-off without touching test-only APIs.
  static Future<void> recordProductionReadinessTestNonFatal(
    Object exception,
    StackTrace? stack, {
    required bool fatal,
    required String reason,
  }) {
    return recordCrash(
      exception,
      stack,
      fatal: fatal,
      reason: reason,
    );
  }

  @visibleForTesting
  static void resetRecordingForTest() {
    recordCrash = _defaultRecordCrash;
    setCustomKey = _defaultSetCustomKey;
  }
}
