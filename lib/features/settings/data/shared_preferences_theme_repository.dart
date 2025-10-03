import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesThemeRepository implements ThemeRepository {
  SharedPreferencesThemeRepository([SharedPreferences? instance])
    : _preferencesInstance = instance;

  static const String _preferencesKey = 'theme_mode';
  final SharedPreferences? _preferencesInstance;

  Future<SharedPreferences> _preferences() => _preferencesInstance != null
      ? Future.value(_preferencesInstance)
      : SharedPreferences.getInstance();

  @override
  Future<ThemeMode?> load() async {
    final SharedPreferences preferences = await _preferences();
    final String? stored = preferences.getString(_preferencesKey);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }

  @override
  Future<void> save(ThemeMode mode) async {
    final SharedPreferences preferences = await _preferences();
    final String value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await preferences.setString(_preferencesKey, value);
  }
}
