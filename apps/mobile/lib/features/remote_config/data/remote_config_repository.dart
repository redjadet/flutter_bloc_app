import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_keys.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_remote_data_source.dart';
import 'package:flutter_bloc_app/shared/diagnostics/integration_log_messages.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/subscription_manager.dart';

class RemoteConfigRepository implements RemoteConfigRemoteDataSource {
  RemoteConfigRepository(
    this._remoteConfig, {
    final void Function(String message)? debugLogger,
  }) : _logDebug = debugLogger ?? AppLogger.debug;

  static const Duration _fetchTimeout = Duration(minutes: 1);
  static const Duration _minimumFetchInterval = Duration(hours: 1);
  static const Duration _bypassFetchInterval = Duration.zero;

  final FirebaseRemoteConfig _remoteConfig;
  final void Function(String message) _logDebug;

  // ignore: cancel_subscriptions - Subscription managed by SubscriptionManager
  StreamSubscription<RemoteConfigUpdate>? _configUpdatesSubscription;
  bool _isInitialized = false;
  bool _disableFetchDueToKeychain = false;
  final SubscriptionManager _subscriptionManager = SubscriptionManager();

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: _fetchTimeout,
        minimumFetchInterval: _minimumFetchInterval,
      ),
    );
    await _remoteConfig.setDefaults(
      const <String, dynamic>{
        RemoteConfigKeys.awesomeFeatureEnabled: false,
        RemoteConfigKeys.testValue1: '',
        RemoteConfigKeys.supabaseUrl: '',
        RemoteConfigKeys.supabaseAnonKey: '',
        RemoteConfigKeys.supabaseConfigVersion: 1,
        // Default to enabled so missing console wiring doesn't brick config.
        // Remote disable is still supported by setting the key to false.
        RemoteConfigKeys.supabaseConfigEnabled: true,
        RemoteConfigKeys.renderChatDemoHfReadToken: '',
      },
    );

    _subscribeToRealtimeUpdates();
  }

  @override
  Future<void> forceFetch() async {
    if (_disableFetchDueToKeychain || _shouldSkipNativeFetchOnAppleDebug) {
      return;
    }
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: _fetchTimeout,
        minimumFetchInterval: _bypassFetchInterval,
      ),
    );
    try {
      await _remoteConfig.fetchAndActivate();
    } on Exception catch (error) {
      if (_looksLikeKeychainEntitlementError(error)) {
        _disableFetchDueToKeychain = true;
        AppLogger.debug(
          '${IntegrationLogMessages.remoteConfigForceFetchDisabledPrefix}. '
          'Apple debug/simulator unsigned builds cannot use Firebase Installations.',
        );
        return;
      }
      rethrow;
    } finally {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: _fetchTimeout,
          minimumFetchInterval: _minimumFetchInterval,
        ),
      );
    }
    _logTestValue(source: 'fetch');
    _logAwesomeFeatureFlag(source: 'fetch');
  }

  @override
  Future<void> clearCache() async {
    // Firebase Remote Config SDK manages its own cache; nothing to clear here.
  }

  @override
  String getString(final String key) => _remoteConfig.getString(key);

  @override
  bool getBool(final String key) => _remoteConfig.getBool(key);

  @override
  int getInt(final String key) => _remoteConfig.getInt(key);

  @override
  double getDouble(final String key) => _remoteConfig.getDouble(key);

  @override
  Future<void> dispose() async {
    _configUpdatesSubscription = null;
    await _subscriptionManager.dispose();
  }

  void _subscribeToRealtimeUpdates() {
    if (_subscriptionManager.isDisposed || _shouldSkipNativeFetchOnAppleDebug) {
      return;
    }
    _configUpdatesSubscription ??= _remoteConfig.onConfigUpdated.listen(
      (final update) async {
        if (_disableFetchDueToKeychain) return;
        final bool shouldLogTestValue = update.updatedKeys.contains(
          RemoteConfigKeys.testValue1,
        );
        final bool shouldLogAwesomeFeature = update.updatedKeys.contains(
          RemoteConfigKeys.awesomeFeatureEnabled,
        );

        if (!shouldLogTestValue && !shouldLogAwesomeFeature) {
          return;
        }

        try {
          await _remoteConfig.fetchAndActivate();
        } on Exception catch (error, stackTrace) {
          if (_looksLikeKeychainEntitlementError(error)) {
            _disableFetchDueToKeychain = true;
            AppLogger.debug(
              '${IntegrationLogMessages.remoteConfigRealtimeFetchDisabledPrefix}.',
            );
            return;
          }
          AppLogger.error(
            'Remote Config realtime fetch failed for ${RemoteConfigKeys.testValue1}',
            error,
            stackTrace,
          );
          return;
        }

        if (shouldLogTestValue) {
          _logTestValue(source: 'realtime-update');
        }
        if (shouldLogAwesomeFeature) {
          _logAwesomeFeatureFlag(source: 'realtime-update');
        }
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'Remote Config realtime listener error',
          error,
          stackTrace,
        );
      },
    );
    _subscriptionManager.register(_configUpdatesSubscription);
  }

  void _logTestValue({required final String source}) {
    final String value = _remoteConfig.getString(RemoteConfigKeys.testValue1);
    _logDebug(
      'RemoteConfig[$source] ${RemoteConfigKeys.testValue1}="$value"',
    );
  }

  void _logAwesomeFeatureFlag({required final String source}) {
    final bool value = _remoteConfig.getBool(
      RemoteConfigKeys.awesomeFeatureEnabled,
    );
    _logDebug(
      'RemoteConfig[$source] ${RemoteConfigKeys.awesomeFeatureEnabled}=$value',
    );
  }

  static bool _looksLikeKeychainEntitlementError(final Object error) {
    final String message = error.toString();
    return message.contains('-34018') ||
        message.contains('SecItemAdd') ||
        message.contains('required entitlement');
  }

  /// Firebase Installations uses Keychain; iOS simulators and unsigned macOS
  /// debug builds hit -34018. Skip native fetch and rely on defaults/cache.
  static bool get _shouldSkipNativeFetchOnAppleDebug =>
      useInMemorySecretStorageInDebug();
}
