import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/settings/data/shared_preferences_locale_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('SharedPreferencesLocaleRepository saves and loads locales', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final SharedPreferencesLocaleRepository repository =
        SharedPreferencesLocaleRepository(prefs);

    expect(await repository.load(), isNull);

    await repository.save(const Locale('en'));
    expect(await repository.load(), const Locale('en'));

    await repository.save(const Locale('tr', 'TR'));
    expect(await repository.load(), const Locale('tr', 'TR'));

    await repository.save(null);
    expect(await repository.load(), isNull);
  });
}
