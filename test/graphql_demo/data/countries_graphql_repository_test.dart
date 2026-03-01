import 'dart:convert';

import 'package:flutter_bloc_app/features/graphql_demo/data/countries_graphql_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('CountriesGraphqlRepository', () {
    test('fetchContinents parses continent list', () async {
      final repository = CountriesGraphqlRepository(
        client: MockClient((request) async {
          expect(request.url.toString(), 'https://countries.trevorblades.com/');
          final Map<String, dynamic> payload =
              jsonDecode(request.body) as Map<String, dynamic>;
          expect(payload['operationName'], 'Continents');
          expect(payload['query'], contains('continents'));
          return http.Response(
            jsonEncode(<String, Object?>{
              'data': <String, Object?>{
                'continents': <Object?>[
                  <String, String>{'code': 'EU', 'name': 'Europe'},
                  <String, String>{'code': 'NA', 'name': 'North America'},
                ],
              },
            }),
            200,
          );
        }),
      );

      final continents = await repository.fetchContinents();
      expect(continents, hasLength(2));
      expect(continents.first, isA<GraphqlContinent>());
      expect(continents.first.code, 'EU');
    });

    test('fetchCountries returns parsed countries', () async {
      final repository = CountriesGraphqlRepository(
        client: MockClient((request) async {
          final Map<String, dynamic> payload =
              jsonDecode(request.body) as Map<String, dynamic>;
          expect(payload['operationName'], 'AllCountries');
          expect(payload['query'], contains('countries'));
          return http.Response(
            jsonEncode(<String, Object?>{
              'data': <String, Object?>{
                'countries': <Object?>[
                  <String, Object?>{
                    'code': 'DE',
                    'name': 'Germany',
                    'capital': 'Berlin',
                    'currency': 'EUR',
                    'emoji': null,
                    'continent': <String, String>{
                      'code': 'EU',
                      'name': 'Europe',
                    },
                  },
                ],
              },
            }),
            200,
          );
        }),
      );

      final countries = await repository.fetchCountries();
      expect(countries, hasLength(1));
      expect(countries.first.code, 'DE');
      expect(countries.first.continent.name, 'Europe');
    });

    test(
      'fetchCountries uses continent filter variable when provided',
      () async {
        final repository = CountriesGraphqlRepository(
          client: MockClient((request) async {
            final Map<String, dynamic> payload =
                jsonDecode(request.body) as Map<String, dynamic>;
            expect(payload['operationName'], 'CountriesByContinent');
            expect(payload['variables'], <String, Object?>{'continent': 'AS'});
            expect(payload['query'], contains('continent(code'));
            return http.Response(
              jsonEncode(<String, Object?>{
                'data': <String, Object?>{
                  'continent': <String, Object?>{'countries': <Object?>[]},
                },
              }),
              200,
            );
          }),
        );

        await repository.fetchCountries(continentCode: 'AS');
      },
    );

    test('throws GraphqlDemoException on GraphQL errors', () async {
      final repository = CountriesGraphqlRepository(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode(<String, Object?>{
              'errors': <Object?>[
                <String, String>{'message': 'boom'},
              ],
            }),
            200,
          );
        }),
      );

      expect(
        () => AppLogger.silenceAsync(() => repository.fetchCountries()),
        throwsA(isA<GraphqlDemoException>()),
      );
    });

    test(
      'throws GraphqlDemoException with fallback message when first error is malformed',
      () async {
        final repository = CountriesGraphqlRepository(
          client: MockClient((request) async {
            return http.Response(
              jsonEncode(<String, Object?>{
                'errors': <Object?>['unexpected-shape'],
              }),
              200,
            );
          }),
        );

        await expectLater(
          () => AppLogger.silenceAsync(() => repository.fetchCountries()),
          throwsA(
            isA<GraphqlDemoException>().having(
              (final GraphqlDemoException error) => error.message,
              'message',
              'Unknown error',
            ),
          ),
        );
      },
    );

    test('throws GraphqlDemoException on non-200 responses', () async {
      final repository = CountriesGraphqlRepository(
        client: MockClient((request) async => http.Response('error', 500)),
      );

      expect(
        () => AppLogger.silenceAsync(() => repository.fetchContinents()),
        throwsA(isA<GraphqlDemoException>()),
      );
    });
  });
}
