import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/countries_graphql_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('CountriesGraphqlRepository', () {
    late CountriesGraphqlRepository repository;

    group('fetchContinents', () {
      test('returns mapped continents on success', () async {
        final http.Client client = MockClient(
          (_) async => http.Response(
            '{"data":{"continents":[{"code":"AF","name":"Africa"}]}}',
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          ),
        );
        repository = CountriesGraphqlRepository(client: client);

        final continents = await repository.fetchContinents();

        expect(continents, isA<List<GraphqlContinent>>());
        expect(continents.length, 1);
        expect(continents.first.code, 'AF');
        expect(continents.first.name, 'Africa');
      });

      test('throws GraphqlDemoException on non-200 response', () async {
        final http.Client client = MockClient(
          (_) async => http.Response('', 404),
        );
        repository = CountriesGraphqlRepository(client: client);

        await expectLater(
          repository.fetchContinents(),
          throwsA(isA<GraphqlDemoException>()),
        );
      });
    });

    group('fetchCountries', () {
      test('returns all countries when no continent code provided', () async {
        final http.Client client = MockClient(
          (_) async => http.Response(
            '{"data":{"countries":[{"code":"AD","name":"Andorra","continent":{"code":"EU","name":"Europe"}}]}}',
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          ),
        );
        repository = CountriesGraphqlRepository(client: client);

        final countries = await repository.fetchCountries();

        expect(countries, isA<List<GraphqlCountry>>());
        expect(countries.length, 1);
        expect(countries.first.code, 'AD');
        expect(countries.first.name, 'Andorra');
      });

      test('returns continent-specific countries when code provided', () async {
        final http.Client client = MockClient(
          (_) async => http.Response(
            '{"data":{"continent":{"countries":[{"code":"AD","name":"Andorra","continent":{"code":"EU","name":"Europe"}}]}}}',
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          ),
        );
        repository = CountriesGraphqlRepository(client: client);

        final countries = await repository.fetchCountries(continentCode: 'EU');

        expect(countries, isA<List<GraphqlCountry>>());
        expect(countries.length, 1);
        expect(countries.first.code, 'AD');
        expect(countries.first.name, 'Andorra');
      });

      test('throws GraphqlDemoException on non-200 response', () async {
        final http.Client client = MockClient(
          (_) async => http.Response('', 404),
        );
        repository = CountriesGraphqlRepository(client: client);

        await expectLater(
          repository.fetchCountries(),
          throwsA(isA<GraphqlDemoException>()),
        );
      });
    });
  });
}
