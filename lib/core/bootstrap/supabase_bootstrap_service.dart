import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service responsible for Supabase initialization when URL and anon key
/// are configured. Does not block app startup if keys are missing.
class SupabaseBootstrapService {
  SupabaseBootstrapService._();

  static bool _initialized = false;
  static Future<void>? _initialization;
  @visibleForTesting
  static Future<void> Function({
    required String url,
    required String anonKey,
  })
  initializeClient = _defaultInitializeClient;

  /// Whether Supabase has been successfully initialized (URL and anon key
  /// were present and [initializeSupabase] completed without error).
  static bool get isSupabaseInitialized => _initialized;

  /// Initializes Supabase when [SecretConfig.supabaseUrl] and
  /// [SecretConfig.supabaseAnonKey] are non-empty. Safe to call multiple
  /// times; only initializes once. Does not throw.
  static Future<void> initializeSupabase() {
    if (_initialized) {
      return Future<void>.value();
    }

    return _initialization ??= _initializeSupabaseOnce().whenComplete(() {
      if (!_initialized) {
        _initialization = null;
      }
    });
  }

  /// Late-init safe alias for runtime initialization.
  ///
  /// Call this after `SecretConfig.applySupabaseConfig(...)` (and secure-storage
  /// persistence) when config arrives after app startup.
  static Future<void> initializeIfNeeded() => initializeSupabase();

  static Future<void> _initializeSupabaseOnce() async {
    final String? url = SecretConfig.supabaseUrl?.trim();
    final String? anonKey = SecretConfig.supabaseAnonKey?.trim();

    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      AppLogger.debug(
        'Supabase init skipped: SUPABASE_URL or SUPABASE_ANON_KEY not set.',
      );
      return;
    }

    if (_hasCachedConfigProjectMismatch()) {
      AppLogger.warning(
        'Supabase init skipped: cached config belongs to a different Firebase project.',
      );
      return;
    }

    try {
      await initializeClient(url: url, anonKey: anonKey);
      _initialized = true;
      AppLogger.info('Supabase initialized');
    } on Object catch (error, stackTrace) {
      AppLogger.warning('Supabase initialization failed');
      AppLogger.error(
        'SupabaseBootstrapService.initializeSupabase',
        error,
        stackTrace,
      );
    }
  }

  @visibleForTesting
  static void resetForTest() {
    _initialized = false;
    _initialization = null;
    initializeClient = _defaultInitializeClient;
  }

  static Future<void> _defaultInitializeClient({
    required final String url,
    required final String anonKey,
  }) => Supabase.initialize(url: url, anonKey: anonKey);

  static bool _hasCachedConfigProjectMismatch() {
    final String? cachedProjectId = SecretConfig.supabaseFirebaseProjectId
        ?.trim();
    if (cachedProjectId == null || cachedProjectId.isEmpty) {
      return false;
    }
    if (!FirebaseBootstrapService.isFirebaseInitialized) {
      return false;
    }
    try {
      final FirebaseApp app = Firebase.app();
      final String activeProjectId = app.options.projectId.trim();
      return activeProjectId.isNotEmpty && activeProjectId != cachedProjectId;
    } on Object {
      return false;
    }
  }
}
