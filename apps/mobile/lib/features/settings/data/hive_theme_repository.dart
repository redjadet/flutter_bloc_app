import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:storage/storage.dart';

/// Hive-backed implementation of [ThemeRepository].
class HiveThemeRepository extends HiveSettingsRepository<ThemePreference>
    implements ThemeRepository {
  HiveThemeRepository({required super.hiveService})
    : super(
        key: 'theme_mode',
        fromString: _parseThemePreference,
        toStringValue: _themePreferenceToString,
      );

  static ThemePreference? _parseThemePreference(String value) =>
      switch (value) {
        'light' => ThemePreference.light,
        'dark' => ThemePreference.dark,
        'system' => ThemePreference.system,
        _ => null,
      };

  static String _themePreferenceToString(ThemePreference preference) =>
      switch (preference) {
        ThemePreference.light => 'light',
        ThemePreference.dark => 'dark',
        ThemePreference.system => 'system',
      };
}
