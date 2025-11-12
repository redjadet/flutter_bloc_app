import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive-backed implementation of [ThemeRepository].
class HiveThemeRepository extends HiveRepositoryBase
    implements ThemeRepository {
  HiveThemeRepository({required super.hiveService});

  static const String _boxName = 'settings';
  static const String _keyTheme = 'theme_mode';

  @override
  String get boxName => _boxName;

  @override
  Future<ThemePreference?> load() async => StorageGuard.run<ThemePreference?>(
    logContext: 'HiveThemeRepository.load',
    action: () async {
      final Box<dynamic> box = await getBox();
      final dynamic themeValue = box.get(_keyTheme);

      // Validate type and content
      if (themeValue is! String || themeValue.isEmpty) {
        return null;
      }

      final ThemePreference? preference = switch (themeValue) {
        'light' => ThemePreference.light,
        'dark' => ThemePreference.dark,
        'system' => ThemePreference.system,
        _ => null,
      };

      // Clean up invalid data if found
      if (preference == null) {
        AppLogger.warning(
          'Invalid theme mode in Hive: $themeValue, cleaning up',
        );
        await safeDeleteKey(box, _keyTheme);
      }

      return preference;
    },
    fallback: () => null,
  );

  @override
  Future<void> save(final ThemePreference mode) async => StorageGuard.run<void>(
    logContext: 'HiveThemeRepository.save',
    action: () async {
      final Box<dynamic> box = await getBox();
      final String value = switch (mode) {
        ThemePreference.light => 'light',
        ThemePreference.dark => 'dark',
        ThemePreference.system => 'system',
      };
      await box.put(_keyTheme, value);
    },
    fallback: () {},
  );
}
