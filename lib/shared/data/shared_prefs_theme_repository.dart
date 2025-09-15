import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/domain/theme_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesThemeRepository implements ThemeRepository {
  static const String _prefsKey = 'theme_mode';

  @override
  Future<ThemeMode?> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_prefsKey, value);
  }
}

