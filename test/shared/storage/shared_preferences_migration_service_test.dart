import 'dart:io';

import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/storage/shared_preferences_migration_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPreferencesMigrationService', () {
    late Directory testDir;
    late HiveService hiveService;
    late HiveKeyManager keyManager;
    late InMemorySecretStorage storage;
    late SharedPreferencesMigrationService migrationService;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      testDir = Directory.systemTemp.createTempSync('hive_test_');
      Hive.init(testDir.path);
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      storage = InMemorySecretStorage();
      keyManager = HiveKeyManager(storage: storage);
      hiveService = HiveService(keyManager: keyManager);
      await hiveService.initialize();
      migrationService = SharedPreferencesMigrationService(
        hiveService: hiveService,
      );
    });

    tearDown(() async {
      try {
        await hiveService.closeBox('migration');
        await hiveService.closeBox('counter');
        await hiveService.closeBox('settings');
        await hiveService.deleteBox('migration');
        await hiveService.deleteBox('counter');
        await hiveService.deleteBox('settings');
      } catch (_) {
        // Boxes might not exist
      }
    });

    tearDownAll(() {
      testDir.deleteSync(recursive: true);
    });

    group('isMigrationCompleted', () {
      test('returns false when migration has not been completed', () async {
        final bool result = await migrationService.isMigrationCompleted();
        expect(result, isFalse);
      });

      test('returns true after migration is completed', () async {
        // Perform migration first
        SharedPreferences.setMockInitialValues(<String, Object>{
          'last_count': 5,
        });
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final SharedPreferencesMigrationService serviceWithPrefs =
            SharedPreferencesMigrationService(
              hiveService: hiveService,
              sharedPreferences: prefs,
            );

        await serviceWithPrefs.migrateIfNeeded();

        final bool result = await migrationService.isMigrationCompleted();
        expect(result, isTrue);
      });
    });

    group('migrateIfNeeded', () {
      test('skips migration when already completed', () async {
        // First migration
        SharedPreferences.setMockInitialValues(<String, Object>{
          'last_count': 5,
        });
        final SharedPreferences prefs1 = await SharedPreferences.getInstance();
        final SharedPreferencesMigrationService service1 =
            SharedPreferencesMigrationService(
              hiveService: hiveService,
              sharedPreferences: prefs1,
            );
        await service1.migrateIfNeeded();

        // Second migration attempt
        SharedPreferences.setMockInitialValues(<String, Object>{
          'last_count': 10,
        });
        final SharedPreferences prefs2 = await SharedPreferences.getInstance();
        final SharedPreferencesMigrationService service2 =
            SharedPreferencesMigrationService(
              hiveService: hiveService,
              sharedPreferences: prefs2,
            );
        await service2.migrateIfNeeded();

        // Verify original value is preserved
        final Box<dynamic> counterBox = await hiveService.openBox('counter');
        expect(counterBox.get('count'), 5);
      });

      test('migrates counter data from SharedPreferences', () async {
        final DateTime timestamp = DateTime(2024, 1, 1, 12);
        SharedPreferences.setMockInitialValues(<String, Object>{
          'last_count': 7,
          'last_changed': timestamp.millisecondsSinceEpoch,
        });

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final SharedPreferencesMigrationService service =
            SharedPreferencesMigrationService(
              hiveService: hiveService,
              sharedPreferences: prefs,
            );

        await service.migrateIfNeeded();

        final Box<dynamic> counterBox = await hiveService.openBox('counter');
        expect(counterBox.get('count'), 7);
        expect(
          counterBox.get('last_changed'),
          timestamp.millisecondsSinceEpoch,
        );
        expect(counterBox.get('user_id'), 'local');
      });

      test('migrates locale data from SharedPreferences', () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'preferred_locale_code': 'tr',
        });

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final SharedPreferencesMigrationService service =
            SharedPreferencesMigrationService(
              hiveService: hiveService,
              sharedPreferences: prefs,
            );

        await service.migrateIfNeeded();

        final Box<dynamic> settingsBox = await hiveService.openBox('settings');
        expect(settingsBox.get('preferred_locale_code'), 'tr');
      });

      test('migrates theme data from SharedPreferences', () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'theme_mode': 'dark',
        });

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final SharedPreferencesMigrationService service =
            SharedPreferencesMigrationService(
              hiveService: hiveService,
              sharedPreferences: prefs,
            );

        await service.migrateIfNeeded();

        final Box<dynamic> settingsBox = await hiveService.openBox('settings');
        expect(settingsBox.get('theme_mode'), 'dark');
      });

      test('migrates all data types together', () async {
        final DateTime timestamp = DateTime(2024, 2, 1, 9, 30);
        SharedPreferences.setMockInitialValues(<String, Object>{
          'last_count': 10,
          'last_changed': timestamp.millisecondsSinceEpoch,
          'preferred_locale_code': 'de',
          'theme_mode': 'light',
        });

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final SharedPreferencesMigrationService service =
            SharedPreferencesMigrationService(
              hiveService: hiveService,
              sharedPreferences: prefs,
            );

        await service.migrateIfNeeded();

        final Box<dynamic> counterBox = await hiveService.openBox('counter');
        expect(counterBox.get('count'), 10);
        expect(
          counterBox.get('last_changed'),
          timestamp.millisecondsSinceEpoch,
        );

        final Box<dynamic> settingsBox = await hiveService.openBox('settings');
        expect(settingsBox.get('preferred_locale_code'), 'de');
        expect(settingsBox.get('theme_mode'), 'light');
      });

      test('handles invalid counter data gracefully', () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'last_count': 'invalid',
          'last_changed': 'invalid',
        });

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final SharedPreferencesMigrationService service =
            SharedPreferencesMigrationService(
              hiveService: hiveService,
              sharedPreferences: prefs,
            );

        // Should not throw
        await service.migrateIfNeeded();

        final Box<dynamic> counterBox = await hiveService.openBox('counter');
        // Invalid data should not be migrated
        expect(counterBox.get('count'), isNull);
      });

      test('handles empty locale string', () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'preferred_locale_code': '',
        });

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final SharedPreferencesMigrationService service =
            SharedPreferencesMigrationService(
              hiveService: hiveService,
              sharedPreferences: prefs,
            );

        await service.migrateIfNeeded();

        final Box<dynamic> settingsBox = await hiveService.openBox('settings');
        // Empty string should not be migrated
        expect(settingsBox.get('preferred_locale_code'), isNull);
      });

      test('handles empty theme string', () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'theme_mode': '',
        });

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final SharedPreferencesMigrationService service =
            SharedPreferencesMigrationService(
              hiveService: hiveService,
              sharedPreferences: prefs,
            );

        await service.migrateIfNeeded();

        final Box<dynamic> settingsBox = await hiveService.openBox('settings');
        // Empty string should not be migrated
        expect(settingsBox.get('theme_mode'), isNull);
      });

      test(
        'marks migration complete when at least one migration succeeds',
        () async {
          SharedPreferences.setMockInitialValues(<String, Object>{
            'last_count': 5,
          });

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final SharedPreferencesMigrationService service =
              SharedPreferencesMigrationService(
                hiveService: hiveService,
                sharedPreferences: prefs,
              );

          await service.migrateIfNeeded();

          final bool completed = await service.isMigrationCompleted();
          expect(completed, isTrue);
        },
      );
    });
  });
}
