import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/storage/migration_helpers.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to migrate data from SharedPreferences to Hive database.
class SharedPreferencesMigrationService {
  SharedPreferencesMigrationService({
    required final HiveService hiveService,
    final SharedPreferences? sharedPreferences,
  }) : _hiveService = hiveService,
       _sharedPreferences = sharedPreferences;

  static const String _migrationBoxName = 'migration';
  static const String _migrationKey = 'migration_completed';
  static const String _preferencesKeyCount = 'last_count';
  static const String _preferencesKeyChanged = 'last_changed';
  static const String _preferencesKeyLocale = 'preferred_locale_code';
  static const String _preferencesKeyTheme = 'theme_mode';

  final HiveService _hiveService;
  final SharedPreferences? _sharedPreferences;

  /// Checks if migration has already been completed.
  Future<bool> isMigrationCompleted() async => StorageGuard.run<bool>(
    logContext: 'SharedPreferencesMigrationService.isMigrationCompleted',
    action: () async {
      final Box<dynamic> box = await _hiveService.openBox(
        _migrationBoxName,
        encrypted: false,
      );
      return box.get(_migrationKey, defaultValue: false) as bool;
    },
    fallback: () => false,
  );

  /// Performs migration from SharedPreferences to Hive if needed.
  ///
  /// This method is safe to call multiple times - it will only migrate once.
  Future<void> migrateIfNeeded() async {
    // Double-check pattern to prevent concurrent migrations
    final bool alreadyMigrated = await isMigrationCompleted();
    if (alreadyMigrated) {
      AppLogger.debug('Migration already completed, skipping.');
      return;
    }

    await StorageGuard.run<void>(
      logContext: 'SharedPreferencesMigrationService.migrateIfNeeded',
      action: () async {
        // Double-check again after acquiring lock (if needed)
        final bool stillNeedsMigration = !(await isMigrationCompleted());
        if (!stillNeedsMigration) {
          AppLogger.debug('Migration completed by another process, skipping.');
          return;
        }

        final SharedPreferences prefs =
            _sharedPreferences ?? await SharedPreferences.getInstance();

        // Track migration success for each data type
        bool counterMigrated = false;
        bool localeMigrated = false;
        bool themeMigrated = false;

        try {
          // Migrate counter data
          await _migrateCounterData(prefs);
          counterMigrated = true;
        } on Exception catch (error, stackTrace) {
          AppLogger.error(
            'Failed to migrate counter data',
            error,
            stackTrace,
          );
        }

        try {
          // Migrate locale data
          await _migrateLocaleData(prefs);
          localeMigrated = true;
        } on Exception catch (error, stackTrace) {
          AppLogger.error(
            'Failed to migrate locale data',
            error,
            stackTrace,
          );
        }

        try {
          // Migrate theme data
          await _migrateThemeData(prefs);
          themeMigrated = true;
        } on Exception catch (error, stackTrace) {
          AppLogger.error(
            'Failed to migrate theme data',
            error,
            stackTrace,
          );
        }

        // Mark migration as complete only if at least one migration succeeded
        // This allows retrying failed migrations on next app start
        if (counterMigrated || localeMigrated || themeMigrated) {
          final Box<dynamic> migrationBox = await _hiveService.openBox(
            _migrationBoxName,
            encrypted: false,
          );
          await migrationBox.put(_migrationKey, true);
          AppLogger.info(
            'Migration from SharedPreferences to Hive completed '
            '(counter: $counterMigrated, locale: $localeMigrated, theme: $themeMigrated)',
          );
        } else {
          AppLogger.warning(
            'All migration steps failed. Migration will be retried on next app start.',
          );
        }
      },
      fallback: () {
        AppLogger.warning(
          'Migration from SharedPreferences to Hive failed. '
          'App will continue with empty Hive database.',
        );
      },
    );
  }

  Future<void> _migrateCounterData(final SharedPreferences prefs) async {
    final dynamic countValue = prefs.get(_preferencesKeyCount);
    final dynamic changedMsValue = prefs.get(_preferencesKeyChanged);

    // Validate and normalize count
    final int? count = MigrationHelpers.normalizeCount(countValue);

    // Validate and normalize timestamp
    final int? changedMs = MigrationHelpers.normalizeTimestamp(changedMsValue);

    if (count != null || changedMs != null) {
      final Box<dynamic> box = await _hiveService.openBox('counter');
      await box.put('count', count ?? 0);
      if (changedMs != null) {
        await box.put('last_changed', changedMs);
      }
      await box.put('user_id', 'local');
      AppLogger.debug(
        'Migrated counter data: count=$count, changed=$changedMs',
      );
    }
  }

  Future<void> _migrateLocaleData(final SharedPreferences prefs) async {
    final String? localeTag = prefs.getString(_preferencesKeyLocale);
    if (localeTag != null && localeTag.isNotEmpty) {
      final Box<dynamic> box = await _hiveService.openBox('settings');
      await box.put('preferred_locale_code', localeTag);
      AppLogger.debug('Migrated locale data: $localeTag');
    }
  }

  Future<void> _migrateThemeData(final SharedPreferences prefs) async {
    final String? themeMode = prefs.getString(_preferencesKeyTheme);
    if (themeMode != null && themeMode.isNotEmpty) {
      final Box<dynamic> box = await _hiveService.openBox('settings');
      await box.put('theme_mode', themeMode);
      AppLogger.debug('Migrated theme data: $themeMode');
    }
  }
}
