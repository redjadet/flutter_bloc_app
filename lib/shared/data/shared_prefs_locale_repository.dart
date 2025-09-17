import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/domain/locale_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesLocaleRepository implements LocaleRepository {
  SharedPreferencesLocaleRepository([SharedPreferences? instance])
    : _prefsInstance = instance;

  static const String _prefsKey = 'preferred_locale_code';
  final SharedPreferences? _prefsInstance;

  Future<SharedPreferences> _prefs() => _prefsInstance != null
      ? Future.value(_prefsInstance)
      : SharedPreferences.getInstance();

  @override
  Future<Locale?> load() async {
    final SharedPreferences prefs = await _prefs();
    final String? code = prefs.getString(_prefsKey);
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
    final SharedPreferences prefs = await _prefs();
    if (locale == null) {
      await prefs.remove(_prefsKey);
      return;
    }
    final String code = locale.countryCode == null
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    await prefs.setString(_prefsKey, code);
  }
}
