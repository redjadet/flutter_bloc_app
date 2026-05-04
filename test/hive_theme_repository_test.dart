import 'package:flutter_bloc_app/features/settings/data/hive_theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_bloc_app/shared/storage/hive_schema_migration.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'test_helpers.dart' as test_helpers;

void main() {
  late HiveService hiveService;
  late HiveThemeRepository repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    hiveService = await test_helpers.createHiveService();
    repository = HiveThemeRepository(hiveService: hiveService);
  });

  tearDown(() async {
    await test_helpers.cleanupHiveBoxes(['settings', 'counter']);
  });

  test('HiveThemeRepository saves and loads theme mode', () async {
    expect(await repository.load(), isNull);

    await repository.save(ThemePreference.light);
    expect(await repository.load(), ThemePreference.light);

    await repository.save(ThemePreference.dark);
    expect(await repository.load(), ThemePreference.dark);

    await repository.save(ThemePreference.system);
    expect(await repository.load(), ThemePreference.system);
  });

  test('HiveThemeRepository cleans up invalid stored values', () async {
    final Box<dynamic> box = await hiveService.openBox(
      'settings',
      encrypted: false,
    );
    await box.put('theme_mode', 'not-a-real-theme');

    expect(await repository.load(), isNull);
    expect(box.get('theme_mode'), isNull);

    final dynamic meta = box.get(HiveSchemaMigratorService.metaKeyFingerprints);
    expect(meta, isA<Map>());
    expect((meta as Map)['settings:theme_mode'], isNotNull);
  });
}
