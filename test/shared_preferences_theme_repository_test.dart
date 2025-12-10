import 'package:flutter_bloc_app/features/settings/data/shared_preferences_theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  setUpAll(() {
    registerFallbackValue('');
  });

  test('SharedPreferencesThemeRepository saves and loads theme mode', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final SharedPreferencesThemeRepository repository =
        SharedPreferencesThemeRepository(prefs);

    expect(await repository.load(), isNull);

    await repository.save(ThemePreference.light);
    expect(await repository.load(), ThemePreference.light);

    await repository.save(ThemePreference.dark);
    expect(await repository.load(), ThemePreference.dark);

    await repository.save(ThemePreference.system);
    expect(await repository.load(), ThemePreference.system);
  });

  test(
    'SharedPreferencesThemeRepository load handles storage errors',
    () async {
      final _MockSharedPreferences prefs = _MockSharedPreferences();
      when(() => prefs.getString(any())).thenThrow(Exception('boom'));

      final SharedPreferencesThemeRepository repository =
          SharedPreferencesThemeRepository(prefs);

      final ThemePreference? result = await repository.load();
      expect(result, isNull);
    },
  );

  test(
    'SharedPreferencesThemeRepository save handles storage errors',
    () async {
      final _MockSharedPreferences prefs = _MockSharedPreferences();
      when(() => prefs.setString(any(), any())).thenThrow(Exception('boom'));

      final SharedPreferencesThemeRepository repository =
          SharedPreferencesThemeRepository(prefs);

      expect(repository.save(ThemePreference.dark), completes);
    },
  );
}
