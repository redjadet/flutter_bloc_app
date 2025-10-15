import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesLocaleRepository implements LocaleRepository {
  SharedPreferencesLocaleRepository([SharedPreferences? instance])
    : _preferencesInstance = instance;

  static const String _preferencesKey = 'preferred_locale_code';
  final SharedPreferences? _preferencesInstance;

  Future<SharedPreferences> _preferences() => _preferencesInstance != null
      ? Future.value(_preferencesInstance)
      : SharedPreferences.getInstance();

  @override
  Future<Locale?> load() async {
    final SharedPreferences preferences = await _preferences();
    final String? code = preferences.getString(_preferencesKey);
    if (code == null || code.isEmpty) {
      return null;
    }
    final List<String> parts = code.split('_');
    if (parts.length == 1) {
      return Locale(parts.first);
    }
    return Locale(parts.first, parts[1]);
  }

  @override
  Future<void> save(Locale? locale) async {
    final SharedPreferences preferences = await _preferences();
    if (locale == null) {
      await preferences.remove(_preferencesKey);
      return;
    }
    final String code = locale.countryCode == null
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    await preferences.setString(_preferencesKey, code);
  }
}
