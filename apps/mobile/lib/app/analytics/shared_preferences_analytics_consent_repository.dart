import 'dart:async';

import 'package:flutter_bloc_app/app/analytics/analytics_consent_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage/storage.dart';

class SharedPreferencesAnalyticsConsentRepository
    implements AnalyticsConsentRepository {
  SharedPreferencesAnalyticsConsentRepository([
    final SharedPreferences? instance,
  ]) : _preferencesInstance = instance;

  static const String preferencesKey = 'analytics_collection_enabled';

  final SharedPreferences? _preferencesInstance;
  final StreamController<bool> _changesController =
      StreamController<bool>.broadcast();

  @override
  Stream<bool> get changes => _changesController.stream;

  Future<SharedPreferences> _preferences() => _preferencesInstance != null
      ? Future<SharedPreferences>.value(_preferencesInstance)
      : SharedPreferences.getInstance();

  @override
  Future<bool> load() async => StorageGuard.run<bool>(
    logContext: 'SharedPreferencesAnalyticsConsentRepository.load',
    action: () async {
      final SharedPreferences preferences = await _preferences();
      return preferences.getBool(preferencesKey) ?? false;
    },
    fallback: () => false,
  );

  @override
  Future<bool> save({required final bool enabled}) async {
    final bool saved = await StorageGuard.run<bool>(
      logContext: 'SharedPreferencesAnalyticsConsentRepository.save',
      action: () async {
        final SharedPreferences preferences = await _preferences();
        return preferences.setBool(preferencesKey, enabled);
      },
      fallback: () => false,
    );
    if (saved && !_changesController.isClosed) {
      _changesController.add(enabled);
    }
    return saved;
  }

  @override
  Future<void> dispose() async {
    if (!_changesController.isClosed) {
      await _changesController.close();
    }
  }
}
