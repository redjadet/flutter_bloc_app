import 'package:flutter_bloc_app/features/settings/data/shared_preferences_theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
}
