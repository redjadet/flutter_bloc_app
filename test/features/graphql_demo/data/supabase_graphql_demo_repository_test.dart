import 'package:flutter_bloc_app/features/graphql_demo/data/supabase_graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helpers/supabase_test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await initializeSupabaseForTest();
  });

  tearDown(resetSupabaseTestState);

  group('SupabaseGraphqlDemoRepository', () {
    test('throws when Supabase is not configured', () async {
      resetSupabaseTestState();
      final SupabaseGraphqlDemoRepository repository =
          SupabaseGraphqlDemoRepository();

      await expectLater(
        repository.fetchContinents(),
        throwsA(
          isA<GraphqlDemoException>().having(
            (final GraphqlDemoException error) => error.type,
            'type',
            GraphqlDemoErrorType.network,
          ),
        ),
      );
    });

    test('returns edge continents and marks source as edge', () async {
      final SupabaseGraphqlDemoRepository repository =
          SupabaseGraphqlDemoRepository(
            readAccessToken: () => 'access-token',
            invokeEdgeFunction:
                ({
                  required final String functionName,
                  required final String accessToken,
                  required final Map<String, dynamic> body,
                }) async {
                  expect(functionName, 'sync-graphql-countries');
                  expect(accessToken, 'access-token');
                  expect(body, const <String, dynamic>{'type': 'continents'});
                  return FunctionResponse(
                    status: 200,
                    data: <String, dynamic>{
                      'continents': <Map<String, Object?>>[
                        <String, Object?>{'code': 'EU', 'name': 'Europe'},
                        <String, Object?>{'code': null, 'name': 'Invalid'},
                      ],
                    },
                  );
                },
            fetchContinentRows: () async =>
                throw StateError('tables should not be used'),
          );

      final List<GraphqlContinent> continents = await repository
          .fetchContinents();

      expect(continents, const <GraphqlContinent>[
        GraphqlContinent(code: 'EU', name: 'Europe'),
      ]);
      expect(repository.lastSource, GraphqlDataSource.supabaseEdge);
    });

    test(
      'falls back to table countries and normalizes continent code',
      () async {
        String? requestedCode;
        final SupabaseGraphqlDemoRepository
        repository = SupabaseGraphqlDemoRepository(
          readAccessToken: () => 'access-token',
          invokeEdgeFunction:
              ({
                required final String functionName,
                required final String accessToken,
                required final Map<String, dynamic> body,
              }) async => FunctionResponse(
                status: 200,
                data: <String, dynamic>{'countries': null},
              ),
          fetchCountryRows: (final code) async {
            requestedCode = code;
            return <Map<String, Object?>>[
              <String, Object?>{
                'code': 'FR',
                'name': 'France',
                'continent': <String, Object?>{'code': 'EU', 'name': 'Europe'},
              },
              <String, Object?>{
                'code': 'DE',
                'name': null,
                'continent': <String, Object?>{'code': 'EU', 'name': 'Europe'},
              },
            ];
          },
        );

        final List<GraphqlCountry> countries = await repository.fetchCountries(
          continentCode: ' eu ',
        );

        expect(requestedCode, 'EU');
        expect(countries, const <GraphqlCountry>[
          GraphqlCountry(
            code: 'FR',
            name: 'France',
            continent: GraphqlContinent(code: 'EU', name: 'Europe'),
          ),
        ]);
        expect(repository.lastSource, GraphqlDataSource.supabaseTables);
      },
    );

    test(
      'maps Postgrest country fetch errors to GraphqlDemoException',
      () async {
        const PostgrestException failure = PostgrestException(
          message: 'db unavailable',
          code: '503',
        );
        final SupabaseGraphqlDemoRepository repository =
            SupabaseGraphqlDemoRepository(
              readAccessToken: () => null,
              fetchCountryRows: (final _) async => throw failure,
            );

        await expectLater(
          repository.fetchCountries(continentCode: 'eu'),
          throwsA(
            isA<GraphqlDemoException>()
                .having(
                  (final GraphqlDemoException error) => error.message,
                  'message',
                  'db unavailable',
                )
                .having(
                  (final GraphqlDemoException error) => error.type,
                  'type',
                  GraphqlDemoErrorType.server,
                )
                .having(
                  (final GraphqlDemoException error) => error.cause,
                  'cause',
                  same(failure),
                ),
          ),
        );
      },
    );
  });
}
