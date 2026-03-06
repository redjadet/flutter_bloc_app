import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/countries_graphql_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Dio createMockDio(final String body, final int statusCode) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<String>(
              requestOptions: options,
              data: body,
              statusCode: statusCode,
            ),
          );
        },
      ),
    );
    return dio;
  }

  group('CountriesGraphqlRepository', () {
    late CountriesGraphqlRepository repository;

    group('fetchContinents', () {
      test('returns mapped continents on success', () async {
        final Dio client = createMockDio(
          '{"data":{"continents":[{"code":"AF","name":"Africa"}]}}',
          200,
        );
        repository = CountriesGraphqlRepository(client: client);

        final continents = await repository.fetchContinents();

        expect(continents, isA<List<GraphqlContinent>>());
        expect(continents.length, 1);
        expect(continents.first.code, 'AF');
        expect(continents.first.name, 'Africa');
      });

      test('throws GraphqlDemoException on non-200 response', () async {
        final Dio client = createMockDio('', 404);
        repository = CountriesGraphqlRepository(client: client);

        await expectLater(
          repository.fetchContinents(),
          throwsA(isA<GraphqlDemoException>()),
        );
      });
    });

    group('fetchCountries', () {
      test('returns all countries when no continent code provided', () async {
        final Dio client = createMockDio(
          '{"data":{"countries":[{"code":"AD","name":"Andorra","continent":{"code":"EU","name":"Europe"}}]}}',
          200,
        );
        repository = CountriesGraphqlRepository(client: client);

        final countries = await repository.fetchCountries();

        expect(countries, isA<List<GraphqlCountry>>());
        expect(countries.length, 1);
        expect(countries.first.code, 'AD');
        expect(countries.first.name, 'Andorra');
      });

      test('returns continent-specific countries when code provided', () async {
        final Dio client = createMockDio(
          '{"data":{"continent":{"countries":[{"code":"AD","name":"Andorra","continent":{"code":"EU","name":"Europe"}}]}}}',
          200,
        );
        repository = CountriesGraphqlRepository(client: client);

        final countries = await repository.fetchCountries(continentCode: 'EU');

        expect(countries, isA<List<GraphqlCountry>>());
        expect(countries.length, 1);
        expect(countries.first.code, 'AD');
        expect(countries.first.name, 'Andorra');
      });

      test('throws GraphqlDemoException on non-200 response', () async {
        final Dio client = createMockDio('', 404);
        repository = CountriesGraphqlRepository(client: client);

        await expectLater(
          repository.fetchCountries(),
          throwsA(isA<GraphqlDemoException>()),
        );
      });
    });
  });
}
