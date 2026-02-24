import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/subscription_manager.dart';

class RemoteConfigRepository implements RemoteConfigService {
  RemoteConfigRepository(
    this._remoteConfig, {
    final void Function(String message)? debugLogger,
  }) : _logDebug = debugLogger ?? AppLogger.debug;

  static const String awesomeFeatureKey = 'awesome_feature_enabled';
  static const String testValueKey = 'test_value_1';

  final FirebaseRemoteConfig _remoteConfig;
  final void Function(String message) _logDebug;

  // ignore: cancel_subscriptions - Subscription managed by SubscriptionManager
  StreamSubscription<RemoteConfigUpdate>? _configUpdatesSubscription;
  bool _isInitialized = false;
  final SubscriptionManager _subscriptionManager = SubscriptionManager();

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await _remoteConfig.setDefaults(
      const <String, dynamic>{
        awesomeFeatureKey: false,
        testValueKey: '',
      },
    );

    _subscribeToRealtimeUpdates();
  }

  @override
  Future<void> forceFetch() async {
    await _remoteConfig.fetchAndActivate();
    _logTestValue(source: 'fetch');
    _logAwesomeFeatureFlag(source: 'fetch');
  }

  @override
  Future<void> clearCache() async {
    // Firebase Remote Config SDK manages its own cache; nothing to clear here.
  }

  @override
  String getString(final String key) {
    final String value = _remoteConfig.getString(key);

    if (key == testValueKey) {
      _logDebug('RemoteConfig[getString] $key="$value"');
    }

    return value;
  }

  @override
  bool getBool(final String key) {
    final bool value = _remoteConfig.getBool(key);

    if (key == awesomeFeatureKey) {
      _logDebug('RemoteConfig[getBool] $key=$value');
    }

    return value;
  }

  @override
  int getInt(final String key) => _remoteConfig.getInt(key);

  @override
  double getDouble(final String key) => _remoteConfig.getDouble(key);

  Future<void> dispose() async {
    _configUpdatesSubscription = null;
    await _subscriptionManager.dispose();
    _isInitialized = false;
  }

  void _subscribeToRealtimeUpdates() {
    if (_subscriptionManager.isDisposed) return;
    _configUpdatesSubscription ??= _remoteConfig.onConfigUpdated.listen(
      (final update) async {
        final bool shouldLogTestValue = update.updatedKeys.contains(
          testValueKey,
        );
        final bool shouldLogAwesomeFeature = update.updatedKeys.contains(
          awesomeFeatureKey,
        );

        if (!shouldLogTestValue && !shouldLogAwesomeFeature) {
          return;
        }

        try {
          await _remoteConfig.fetchAndActivate();
        } on Exception catch (error, stackTrace) {
          AppLogger.error(
            'Remote Config realtime fetch failed for $testValueKey',
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
    final String value = _remoteConfig.getString(testValueKey);
    _logDebug('RemoteConfig[$source] $testValueKey="$value"');
  }

  void _logAwesomeFeatureFlag({required final String source}) {
    final bool value = _remoteConfig.getBool(awesomeFeatureKey);
    _logDebug('RemoteConfig[$source] $awesomeFeatureKey=$value');
  }
}
