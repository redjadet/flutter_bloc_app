import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/domain/theme_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesThemeRepository implements ThemeRepository {
  SharedPreferencesThemeRepository([SharedPreferences? instance]) : _prefsInstance = instance;

  static const String _prefsKey = 'theme_mode';
  final SharedPreferences? _prefsInstance;

  Future<SharedPreferences> _prefs() =>
      _prefsInstance != null ? Future.value(_prefsInstance) : SharedPreferences.getInstance();

  @override
  Future<ThemeMode?> load() async {
    final SharedPreferences prefs = await _prefs();
    final String? stored = prefs.getString(_prefsKey);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }

  @override
  Future<void> save(ThemeMode mode) async {
    final SharedPreferences prefs = await _prefs();
    final String value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_prefsKey, value);
  }
}
