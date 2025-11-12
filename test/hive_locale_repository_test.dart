import 'package:flutter_bloc_app/features/settings/data/hive_locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

void main() {
  late HiveService hiveService;
  late HiveLocaleRepository repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Initialize Hive for testing with a test directory
    final Directory testDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(testDir.path);
  });

  setUp(() async {
    // Create fresh service and repository for each test
    final InMemorySecretStorage storage = InMemorySecretStorage();
    final HiveKeyManager keyManager = HiveKeyManager(storage: storage);
    hiveService = HiveService(keyManager: keyManager);
    await hiveService.initialize();
    repository = HiveLocaleRepository(hiveService: hiveService);
  });

  tearDown(() async {
    try {
      await Hive.deleteBoxFromDisk('settings');
    } catch (_) {
      // Box might not exist
    }
    try {
      await Hive.deleteBoxFromDisk('counter');
    } catch (_) {
      // Box might not exist
    }
  });

  test('HiveLocaleRepository saves and loads locales', () async {
    expect(await repository.load(), isNull);

    await repository.save(const AppLocale(languageCode: 'en'));
    expect(await repository.load(), const AppLocale(languageCode: 'en'));

    await repository.save(
      const AppLocale(languageCode: 'tr', countryCode: 'TR'),
    );
    expect(
      await repository.load(),
      const AppLocale(languageCode: 'tr', countryCode: 'TR'),
    );

    await repository.save(null);
    expect(await repository.load(), isNull);
  });
}
