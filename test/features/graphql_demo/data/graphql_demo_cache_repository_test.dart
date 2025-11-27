import 'dart:io';

import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_demo_cache_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late HiveService hiveService;
  late GraphqlDemoCacheRepository repository;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('graphql_cache_test_');
    Hive.init(tempDir.path);
    hiveService = HiveService(
      keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
    );
    await hiveService.initialize();
    repository = GraphqlDemoCacheRepository(hiveService: hiveService);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('persists and retrieves continents', () async {
    final List<GraphqlContinent> continents = <GraphqlContinent>[
      const GraphqlContinent(code: 'EU', name: 'Europe'),
      const GraphqlContinent(code: 'AS', name: 'Asia'),
    ];

    await repository.writeContinents(continents);
    final List<GraphqlContinent> result = await repository.readContinents();

    expect(result, continents);
  });

  test('persists and retrieves countries per continent filter', () async {
    const GraphqlCountry france = GraphqlCountry(
      code: 'FR',
      name: 'France',
      capital: 'Paris',
      currency: 'EUR',
      emoji: '🇫🇷',
      continent: GraphqlContinent(code: 'EU', name: 'Europe'),
    );
    const GraphqlCountry japan = GraphqlCountry(
      code: 'JP',
      name: 'Japan',
      capital: 'Tokyo',
      currency: 'JPY',
      emoji: '🇯🇵',
      continent: GraphqlContinent(code: 'AS', name: 'Asia'),
    );

    await repository.writeCountries(
      countries: <GraphqlCountry>[france, japan],
      continentCode: 'all',
    );
    await repository.writeCountries(
      countries: <GraphqlCountry>[japan],
      continentCode: 'AS',
    );

    final List<GraphqlCountry> all = await repository.readCountries();
    final List<GraphqlCountry> asia = await repository.readCountries(
      continentCode: 'AS',
    );

    expect(all, <GraphqlCountry>[france, japan]);
    expect(asia, <GraphqlCountry>[japan]);
  });

  test('returns empty when cache is stale', () async {
    const GraphqlCountry france = GraphqlCountry(
      code: 'FR',
      name: 'France',
      capital: 'Paris',
      currency: 'EUR',
      emoji: '🇫🇷',
      continent: GraphqlContinent(code: 'EU', name: 'Europe'),
    );

    await repository.writeCountries(
      countries: <GraphqlCountry>[france],
      continentCode: 'EU',
    );

    final List<GraphqlCountry> stale = await repository.readCountries(
      continentCode: 'EU',
      maxAge: Duration.zero,
    );

    expect(stale, isEmpty);
  });
}
