import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/settings/data/shared_preferences_theme_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('SharedPreferencesThemeRepository saves and loads theme mode', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final SharedPreferencesThemeRepository repository =
        SharedPreferencesThemeRepository(prefs);

    expect(await repository.load(), isNull);

    await repository.save(ThemeMode.light);
    expect(await repository.load(), ThemeMode.light);

    await repository.save(ThemeMode.dark);
    expect(await repository.load(), ThemeMode.dark);

    await repository.save(ThemeMode.system);
    expect(await repository.load(), ThemeMode.system);
  });
}
