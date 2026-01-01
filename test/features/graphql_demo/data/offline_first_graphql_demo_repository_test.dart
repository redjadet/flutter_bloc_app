import 'package:flutter_bloc_app/features/graphql_demo/data/countries_graphql_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/offline_first_graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteRepository extends Mock
    implements CountriesGraphqlRepository {}

class _MockCacheRepository extends Mock implements GraphqlCacheRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const GraphqlCountry(
        code: 'FR',
        name: 'France',
        continent: GraphqlContinent(code: 'EU', name: 'Europe'),
      ),
    );
  });

  group('OfflineFirstGraphqlDemoRepository', () {
    late _MockRemoteRepository remote;
    late _MockCacheRepository cache;
    late OfflineFirstGraphqlDemoRepository repository;

    setUp(() {
      remote = _MockRemoteRepository();
      cache = _MockCacheRepository();
      repository = OfflineFirstGraphqlDemoRepository(
        remoteRepository: remote,
        cacheRepository: cache,
      );
    });

    test('falls back to cached continents on failure', () async {
      final List<GraphqlContinent> cached = <GraphqlContinent>[
        const GraphqlContinent(code: 'EU', name: 'Europe'),
      ];
      when(
        () => cache.readContinents(maxAge: any(named: 'maxAge')),
      ).thenAnswer((_) async => cached);
      when(() => remote.fetchContinents()).thenThrow(
        GraphqlDemoException('network', type: GraphqlDemoErrorType.network),
      );

      final List<GraphqlContinent> result = await repository.fetchContinents();

      expect(result, cached);
      verifyNever(() => cache.writeContinents(any()));
    });

    test('caches and returns remote countries on success', () async {
      final List<GraphqlCountry> remoteCountries = <GraphqlCountry>[
        const GraphqlCountry(
          code: 'FR',
          name: 'France',
          continent: GraphqlContinent(code: 'EU', name: 'Europe'),
        ),
      ];
      when(
        () => cache.readCountries(
          continentCode: any(named: 'continentCode'),
          maxAge: any(named: 'maxAge'),
        ),
      ).thenAnswer((_) async => <GraphqlCountry>[]);
      when(
        () => remote.fetchCountries(continentCode: any(named: 'continentCode')),
      ).thenAnswer((_) async => remoteCountries);
      when(
        () => cache.writeCountries(
          countries: remoteCountries,
          continentCode: any(named: 'continentCode'),
        ),
      ).thenAnswer((_) async {});

      final List<GraphqlCountry> result = await repository.fetchCountries(
        continentCode: 'EU',
      );

      expect(result, remoteCountries);
      verify(
        () => cache.writeCountries(
          countries: remoteCountries,
          continentCode: 'EU',
        ),
      ).called(1);
    });

    test('returns cached countries when remote fails', () async {
      final List<GraphqlCountry> cachedCountries = <GraphqlCountry>[
        const GraphqlCountry(
          code: 'FR',
          name: 'France',
          continent: GraphqlContinent(code: 'EU', name: 'Europe'),
        ),
      ];
      when(
        () => cache.readCountries(
          continentCode: any(named: 'continentCode'),
          maxAge: any(named: 'maxAge'),
        ),
      ).thenAnswer((_) async => cachedCountries);
      when(
        () => remote.fetchCountries(continentCode: any(named: 'continentCode')),
      ).thenThrow(
        GraphqlDemoException('network', type: GraphqlDemoErrorType.network),
      );

      final List<GraphqlCountry> result = await repository.fetchCountries(
        continentCode: 'EU',
      );

      expect(result, cachedCountries);
    });
  });
}
