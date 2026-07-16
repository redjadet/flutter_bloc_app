import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_check_attestation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/firebase_app_check_attestation_service.dart';

/// Injectable token reader so tests can avoid the live Firebase App Check
/// plugin. Production wiring defaults to `FirebaseAppCheck.instance.getToken`.
typedef AppCheckTokenReader =
    Future<String?> Function({required bool forceRefresh});

/// [FirebaseAppCheckAttestationService] backed by `firebase_app_check`.
///
/// Only ever probes the cached token via `getToken(false)`; never forces a
/// refresh and never stores or surfaces the token string itself.
///
/// Missing Firebase Console registration is an expected demo state and maps to
/// `unavailable` / `not_configured_or_token_null` (never treated as a crash).
class FirebaseAppCheckAttestationServiceImpl
    implements FirebaseAppCheckAttestationService {
  FirebaseAppCheckAttestationServiceImpl({
    final AppCheckTokenReader? tokenReader,
  }) : _readToken = tokenReader ?? _defaultTokenReader,
       _isFirebaseConfigured = tokenReader == null
           ? _defaultFirebaseConfigured
           : _configuredForInjectedReader;

  final AppCheckTokenReader _readToken;
  final bool Function() _isFirebaseConfigured;

  static Future<String?> _defaultTokenReader({
    required final bool forceRefresh,
  }) => FirebaseAppCheck.instance.getToken(forceRefresh);

  static bool _defaultFirebaseConfigured() => Firebase.apps.isNotEmpty;

  static bool _configuredForInjectedReader() => true;

  @override
  Future<AppCheckAttestationResult> probeCachedToken() async {
    try {
      if (!_isFirebaseConfigured()) {
        return _setupNeededResult;
      }
      final String? token = await _readToken(forceRefresh: false);
      if (token == null || token.isEmpty) {
        return _setupNeededResult;
      }
      return AppCheckAttestationResult(
        status: AppCheckAttestationStatus.issued,
        providerLabel: _configuredProviderLabel(),
        reasonCode: 'ok',
      );
    } on FirebaseException catch (error) {
      if (_looksLikeNotConfigured(error.code)) {
        return _setupNeededResult;
      }
      return const AppCheckAttestationResult(
        status: AppCheckAttestationStatus.failed,
        providerLabel: 'unknown',
        reasonCode: 'app_check_error',
      );
    } on PlatformException catch (error) {
      if (_looksLikeNotConfigured(error.code)) {
        return _setupNeededResult;
      }
      return const AppCheckAttestationResult(
        status: AppCheckAttestationStatus.failed,
        providerLabel: 'unknown',
        reasonCode: 'app_check_error',
      );
    } on Object {
      return const AppCheckAttestationResult(
        status: AppCheckAttestationStatus.failed,
        providerLabel: 'unknown',
        reasonCode: 'app_check_error',
      );
    }
  }

  static const AppCheckAttestationResult _setupNeededResult =
      AppCheckAttestationResult(
        status: AppCheckAttestationStatus.unavailable,
        providerLabel: 'none',
        reasonCode: 'not_configured_or_token_null',
      );

  /// Soft setup signals only — never echo exception messages into state/UI.
  static bool _looksLikeNotConfigured(final String code) {
    final String normalized = code.toLowerCase();
    return normalized.contains('not-activated') ||
        normalized.contains('not_activated') ||
        normalized.contains('not-initialized') ||
        normalized.contains('not_initialized') ||
        normalized.contains('not-registered') ||
        normalized.contains('not_registered') ||
        normalized == 'firebase_app_check' ||
        normalized == 'unknown' ||
        normalized == 'unavailable';
  }

  /// Reports the configured provider chain, not per-token provider provenance.
  static String _configuredProviderLabel() {
    if (kDebugMode) {
      return 'debug';
    }
    if (kIsWeb) {
      return 'unknown';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'play_integrity',
      TargetPlatform.iOS => 'app_attest_with_devicecheck_fallback',
      _ => 'unknown',
    };
  }
}
