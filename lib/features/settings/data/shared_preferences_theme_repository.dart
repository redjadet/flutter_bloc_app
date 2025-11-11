import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesThemeRepository implements ThemeRepository {
  SharedPreferencesThemeRepository([final SharedPreferences? instance])
    : _preferencesInstance = instance;

  static const String _preferencesKey = 'theme_mode';
  final SharedPreferences? _preferencesInstance;

  Future<SharedPreferences> _preferences() => _preferencesInstance != null
      ? Future.value(_preferencesInstance)
      : SharedPreferences.getInstance();

  @override
  Future<ThemePreference?> load() async {
    final SharedPreferences preferences = await _preferences();
    final String? stored = preferences.getString(_preferencesKey);
    return switch (stored) {
      'light' => ThemePreference.light,
      'dark' => ThemePreference.dark,
      'system' => ThemePreference.system,
      _ => null,
    };
  }

  @override
  Future<void> save(final ThemePreference mode) async {
    final SharedPreferences preferences = await _preferences();
    final String value = switch (mode) {
      ThemePreference.light => 'light',
      ThemePreference.dark => 'dark',
      ThemePreference.system => 'system',
    };
    await preferences.setString(_preferencesKey, value);
  }
}
