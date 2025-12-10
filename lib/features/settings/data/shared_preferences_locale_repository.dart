import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesLocaleRepository implements LocaleRepository {
  SharedPreferencesLocaleRepository([final SharedPreferences? instance])
    : _preferencesInstance = instance;

  static const String _preferencesKey = 'preferred_locale_code';
  final SharedPreferences? _preferencesInstance;

  Future<SharedPreferences> _preferences() => _preferencesInstance != null
      ? Future.value(_preferencesInstance)
      : SharedPreferences.getInstance();

  @override
  Future<AppLocale?> load() async => StorageGuard.run<AppLocale?>(
    logContext: 'SharedPreferencesLocaleRepository.load',
    action: () async {
      final SharedPreferences preferences = await _preferences();
      final String? code = preferences.getString(_preferencesKey);
      return AppLocale.fromTag(code);
    },
    fallback: () => null,
  );

  @override
  Future<void> save(final AppLocale? locale) async => StorageGuard.run<void>(
    logContext: 'SharedPreferencesLocaleRepository.save',
    action: () async {
      final SharedPreferences preferences = await _preferences();
      if (locale == null) {
        await preferences.remove(_preferencesKey);
        return;
      }
      await preferences.setString(_preferencesKey, locale.tag);
    },
    fallback: () {},
  );
}
