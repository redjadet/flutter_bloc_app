import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/remote_config/data/repositories/remote_config_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/shared/firebase/auth_helpers.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

@immutable
final class SupabaseConfigFetchResult {
  const SupabaseConfigFetchResult({
    required this.updated,
    required this.skipped,
    this.version,
    this.reason,
  });

  final bool updated;
  final bool skipped;
  final String? version;
  final String? reason;
}

/// Fetches Supabase client config from Firebase Remote Config after the
/// user is signed in with Firebase Auth, then persists + applies it at runtime.
final class SupabaseConfigProvider {
  SupabaseConfigProvider({
    final FirebaseAuth? auth,
    final RemoteConfigService? remoteConfig,
    final SecretStorage? storage,
  }) : _auth = auth,
       _remoteConfig = remoteConfig,
       _storage = storage;

  final FirebaseAuth? _auth;
  final RemoteConfigService? _remoteConfig;
  final SecretStorage? _storage;

  static const String _reasonFirebaseNotInitialized =
      'firebase_not_initialized';
  static const String _reasonFirebaseAuthUnavailable =
      'firebase_auth_unavailable';
  static const String _reasonFirebaseAuthNotReady = 'firebase_auth_not_ready';
  static const String _reasonRemoteConfigUnavailable =
      'remote_config_unavailable';
  static const String _reasonRemoteConfigDisabled = 'remote_config_disabled';
  static const String _reasonInvalidPayload = 'invalid_payload';
  static const String _reasonVersionUnchanged = 'version_unchanged';
  static const String _reasonRemoteConfigFetchFailed =
      'remote_config_fetch_failed';

  Future<SupabaseConfigFetchResult>? _inFlight;

  FirebaseAuth? get _safeAuth {
    if (_auth != null) return _auth;
    try {
      return FirebaseAuth.instance;
    } on Object {
      return null;
    }
  }

  RemoteConfigService? get _safeRemoteConfig {
    if (_remoteConfig != null) return _remoteConfig;
    try {
      return getIt<RemoteConfigService>();
    } on Object {
      return null;
    }
  }

  SecretStorage get _safeStorage =>
      _storage ?? (SecretConfig.storage ?? FlutterSecureSecretStorage());

  /// Fetches config from Remote Config and applies it if it is missing or the
  /// Remote Config `version` differs from the currently loaded one.
  ///
  /// Single-flights concurrent calls to prevent duplicate fetch/init.
  Future<SupabaseConfigFetchResult> fetchAndApplyIfNeeded({
    final bool force = false,
  }) async {
    final existing = _inFlight;
    if (existing != null) return existing;

    final future = _fetchInternal(force: force);
    _inFlight = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlight, future)) {
        _inFlight = null;
      }
    }
  }

  Future<SupabaseConfigFetchResult> _fetchInternal({
    required final bool force,
  }) async {
    final bool requiresFirebaseSingletons =
        _auth == null || _remoteConfig == null;
    if (requiresFirebaseSingletons &&
        !FirebaseBootstrapService.isFirebaseInitialized) {
      return const SupabaseConfigFetchResult(
        updated: false,
        skipped: true,
        reason: _reasonFirebaseNotInitialized,
      );
    }

    final auth = _safeAuth;
    if (auth == null) {
      return const SupabaseConfigFetchResult(
        updated: false,
        skipped: true,
        reason: _reasonFirebaseAuthUnavailable,
      );
    }

    try {
      final user = await waitForAuthUser(auth);
      await user.getIdToken(true);
    } on FirebaseAuthException catch (e, _) {
      AppLogger.info(
        'SupabaseConfigProvider: auth/token not ready (${e.code}); skipping fetch',
      );
      return const SupabaseConfigFetchResult(
        updated: false,
        skipped: true,
        reason: _reasonFirebaseAuthNotReady,
      );
    }

    final RemoteConfigService? remoteConfig = _safeRemoteConfig;
    if (remoteConfig == null) {
      return const SupabaseConfigFetchResult(
        updated: false,
        skipped: true,
        reason: _reasonRemoteConfigUnavailable,
      );
    }

    final String? currentVersion = SecretConfig.supabaseConfigVersion?.trim();
    final bool hasLocalConfig =
        (SecretConfig.supabaseUrl?.trim().isNotEmpty ?? false) &&
        (SecretConfig.supabaseAnonKey?.trim().isNotEmpty ?? false) &&
        (currentVersion?.isNotEmpty ?? false);
    if (hasLocalConfig && !force) {
      // Still allow fetch on version checks when the coordinator decides to,
      // but this provider is used by a single owner. Default here is “missing
      // or forced” to avoid unnecessary traffic.
    }

    try {
      await remoteConfig.initialize();
      try {
        await remoteConfig.forceFetch();
      } on Object {
        // If we already have a valid cached config, do not break the app just
        // because Remote Config is temporarily unavailable.
        if (hasLocalConfig) {
          return const SupabaseConfigFetchResult(
            updated: false,
            skipped: true,
            reason: _reasonRemoteConfigFetchFailed,
          );
        }
        rethrow;
      }

      final String url = remoteConfig
          .getString(RemoteConfigRepository.supabaseUrlKey)
          .trim();
      final String anonKey = remoteConfig
          .getString(RemoteConfigRepository.supabaseAnonKeyKey)
          .trim();
      final int versionNumber = remoteConfig.getInt(
        RemoteConfigRepository.supabaseConfigVersionKey,
      );

      assert(
        () {
          final Uri? uri = Uri.tryParse(url);
          final String host = (uri == null || uri.host.isEmpty)
              ? '(invalid-url)'
              : uri.host;
          AppLogger.debug(
            'SupabaseConfigProvider: source=remote_config '
            'version=$versionNumber host=$host',
          );
          return true;
        }(),
        'SupabaseConfigProvider Remote Config diagnostic',
      );

      final bool enabledFlag = remoteConfig.getBool(
        RemoteConfigRepository.supabaseConfigEnabledKey,
      );
      if (!enabledFlag) {
        return SupabaseConfigFetchResult(
          updated: false,
          skipped: true,
          reason: _reasonRemoteConfigDisabled,
          version: 'rcv:$versionNumber',
        );
      }

      if (versionNumber < 1 || url.isEmpty || anonKey.isEmpty) {
        return const SupabaseConfigFetchResult(
          updated: false,
          skipped: true,
          reason: _reasonInvalidPayload,
        );
      }

      final String version = 'rcv:$versionNumber';
      if (!force && currentVersion != null && currentVersion == version) {
        return SupabaseConfigFetchResult(
          updated: false,
          skipped: false,
          version: version,
          reason: _reasonVersionUnchanged,
        );
      }

      final String? projectId = _tryFirebaseProjectId();
      final storage = _safeStorage;
      await SecretConfig.persistSupabaseConfig(
        storage,
        supabaseUrl: url,
        supabaseAnonKey: anonKey,
        version: version,
        firebaseProjectId: projectId,
      );
      SecretConfig.applySupabaseConfig(
        supabaseUrl: url,
        supabaseAnonKey: anonKey,
        version: version,
        firebaseProjectId: projectId,
      );

      await SupabaseBootstrapService.initializeIfNeeded();

      return SupabaseConfigFetchResult(
        updated: true,
        skipped: false,
        version: version,
      );
    } on Object catch (error, _) {
      AppLogger.info(
        'SupabaseConfigProvider fetch failed (${error.runtimeType})',
      );
      return SupabaseConfigFetchResult(
        updated: false,
        skipped: true,
        reason: error is Exception
            ? error.runtimeType.toString()
            : 'unexpected_error',
      );
    }
  }

  String? _tryFirebaseProjectId() {
    try {
      final FirebaseApp app = Firebase.app();
      final String projectId = app.options.projectId;
      return projectId.trim().isEmpty ? null : projectId.trim();
    } on Object {
      return null;
    }
  }
}
