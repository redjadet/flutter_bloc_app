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
  Future<void> save({required final bool enabled}) async =>
      StorageGuard.run<void>(
        logContext: 'SharedPreferencesAnalyticsConsentRepository.save',
        action: () async {
          final SharedPreferences preferences = await _preferences();
          await preferences.setBool(preferencesKey, enabled);
        },
        fallback: () {},
      );
}
