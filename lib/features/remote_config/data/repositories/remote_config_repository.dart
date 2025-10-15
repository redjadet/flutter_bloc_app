import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class RemoteConfigRepository {
  RemoteConfigRepository(
    this._remoteConfig, {
    void Function(String message)? debugLogger,
  }) : _logDebug = debugLogger ?? AppLogger.debug;

  static const String _awesomeFeatureKey = 'awesome_feature_enabled';
  static const String _testValueKey = 'test_value_1';

  final FirebaseRemoteConfig _remoteConfig;
  final void Function(String message) _logDebug;

  StreamSubscription<RemoteConfigUpdate>? _configUpdatesSubscription;
  bool _isInitialized = false;

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
    await _remoteConfig.setDefaults(const <String, dynamic>{
      _awesomeFeatureKey: false,
      _testValueKey: '',
    });

    _subscribeToRealtimeUpdates();
  }

  Future<void> forceFetch() async {
    await _remoteConfig.fetchAndActivate();
    _logTestValue(source: 'fetch');
    _logAwesomeFeatureFlag(source: 'fetch');
  }

  String getString(String key) {
    final String value = _remoteConfig.getString(key);

    if (key == _testValueKey) {
      _logDebug('RemoteConfig[getString] $key="$value"');
    }

    return value;
  }

  bool getBool(String key) {
    final bool value = _remoteConfig.getBool(key);

    if (key == _awesomeFeatureKey) {
      _logDebug('RemoteConfig[getBool] $key=$value');
    }

    return value;
  }

  int getInt(String key) {
    return _remoteConfig.getInt(key);
  }

  double getDouble(String key) {
    return _remoteConfig.getDouble(key);
  }

  Future<void> dispose() async {
    await _configUpdatesSubscription?.cancel();
    _configUpdatesSubscription = null;
    _isInitialized = false;
  }

  void _subscribeToRealtimeUpdates() {
    _configUpdatesSubscription ??= _remoteConfig.onConfigUpdated.listen(
      (RemoteConfigUpdate update) async {
        final bool shouldLogTestValue = update.updatedKeys.contains(
          _testValueKey,
        );
        final bool shouldLogAwesomeFeature = update.updatedKeys.contains(
          _awesomeFeatureKey,
        );

        if (!shouldLogTestValue && !shouldLogAwesomeFeature) {
          return;
        }

        try {
          await _remoteConfig.fetchAndActivate();
        } on Exception catch (error, stackTrace) {
          AppLogger.error(
            'Remote Config realtime fetch failed for $_testValueKey',
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
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.error(
          'Remote Config realtime listener error',
          error,
          stackTrace,
        );
      },
    );
  }

  void _logTestValue({required String source}) {
    final String value = _remoteConfig.getString(_testValueKey);
    _logDebug('RemoteConfig[$source] $_testValueKey="$value"');
  }

  void _logAwesomeFeatureFlag({required String source}) {
    final bool value = _remoteConfig.getBool(_awesomeFeatureKey);
    _logDebug('RemoteConfig[$source] $_awesomeFeatureKey=$value');
  }
}
