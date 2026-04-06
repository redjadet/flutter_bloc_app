import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/config/supabase_config_provider.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/subscription_manager.dart';

/// Owns the auth-driven Supabase config refresh loop.
///
/// Single owner rule: only this coordinator should trigger fetches based on
/// Firebase Auth lifecycle to avoid duplicate calls and duplicate init attempts.
final class SupabaseConfigCoordinator {
  SupabaseConfigCoordinator({
    required FirebaseAuth auth,
    required SupabaseConfigProvider provider,
    @visibleForTesting
    final Future<SupabaseConfigFetchResult> Function()? fetchAndApplyIfNeeded,
  }) : _auth = auth,
       _provider = provider,
       _fetchAndApplyIfNeeded = fetchAndApplyIfNeeded;

  final FirebaseAuth _auth;
  final SupabaseConfigProvider _provider;
  final Future<SupabaseConfigFetchResult> Function()? _fetchAndApplyIfNeeded;
  final SubscriptionManager _subscriptions = SubscriptionManager();
  bool _started = false;
  Future<void>? _inFlightFetch;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    // Startup path: if a user already exists, attempt fetch/apply in case this
    // device has no cached config yet.
    if (_auth.currentUser != null) {
      unawaited(_safeFetch());
    }

    // Auth refresh path: fetch when a user signs in.
    _subscriptions.register(
      _auth.authStateChanges().listen((final user) {
        if (user == null) {
          // D3 default: keep cached SUPABASE_* on sign-out, so no action here.
          return;
        }
        unawaited(_safeFetch());
      }),
    );
  }

  Future<void> _safeFetch() async {
    final Future<void>? inFlight = _inFlightFetch;
    if (inFlight != null) {
      return inFlight;
    }
    try {
      final Future<SupabaseConfigFetchResult> Function() fetcher =
          _fetchAndApplyIfNeeded ?? _provider.fetchAndApplyIfNeeded;
      final Future<void> fetch = fetcher().then((
        final result,
      ) {
        if (result.updated) {
          AppLogger.info(
            'SupabaseConfigCoordinator: applied supabase config '
            '(version=${result.version ?? '(unknown)'})',
          );
        } else if (result.skipped) {
          AppLogger.info(
            'SupabaseConfigCoordinator: skipped supabase config refresh '
            '(reason=${result.reason ?? 'none'})',
          );
        } else if (!result.skipped) {
          AppLogger.debug(
            'SupabaseConfigCoordinator: no update '
            '(reason=${result.reason ?? 'none'})',
          );
        }
      });
      _inFlightFetch = fetch;
      await fetch;
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'SupabaseConfigCoordinator.fetchAndApplyIfNeeded',
        error,
        stackTrace,
      );
    } finally {
      _inFlightFetch = null;
    }
  }

  Future<void> dispose() => _subscriptions.dispose();
}
