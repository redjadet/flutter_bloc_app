import 'package:flutter_bloc_app/features/settings/data/hive_locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart' as test_helpers;

void main() {
  late HiveService hiveService;
  late HiveLocaleRepository repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    hiveService = await test_helpers.createHiveService();
    repository = HiveLocaleRepository(hiveService: hiveService);
  });

  tearDown(() async {
    await test_helpers.cleanupHiveBoxes(['settings', 'counter']);
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
