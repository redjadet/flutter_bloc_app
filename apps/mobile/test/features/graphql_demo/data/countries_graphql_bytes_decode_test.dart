import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/countries_graphql_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_test/flutter_test.dart';

/// Documents why [CountriesGraphqlRepository] uses byte-first JSON decode:
/// the AllCountries GraphQL payload is large enough to exceed the 8KB isolate
/// threshold used by [decodeJsonMapFromBytes].
void main() {
  test('AllCountries-sized UTF-8 payload exceeds isolate decode threshold', () {
    final String body = _allCountriesPayload(countryCount: 300);
    final List<int> bytes = utf8.encode(body);

    expect(
      bytes.length,
      greaterThan(8 * 1024),
      reason: 'fixture should represent a large GraphQL JSON body',
    );
  });

  test(
    'fetchCountries parses large byte response without string body',
    () async {
      final String body = _allCountriesPayload(countryCount: 300);
      final Dio client = Dio();
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<List<int>>(
                requestOptions: options,
                data: utf8.encode(body),
                statusCode: 200,
              ),
            );
          },
        ),
      );
      final CountriesGraphqlRepository repository = CountriesGraphqlRepository(
        client: client,
      );

      final List<GraphqlCountry> countries = await repository.fetchCountries();

      expect(countries, hasLength(300));
      expect(countries.first.code, 'C000');
      expect(countries.last.code, 'C299');
    },
  );
}

String _allCountriesPayload({required final int countryCount}) {
  final StringBuffer countries = StringBuffer();
  for (var index = 0; index < countryCount; index++) {
    if (index > 0) {
      countries.write(',');
    }
    final String code = 'C${index.toString().padLeft(3, '0')}';
    countries.write(
      '{"code":"$code","name":"Country $index","capital":"Capital $index",'
      '"currency":"USD","emoji":"🏳️",'
      '"continent":{"code":"EU","name":"Europe"}}',
    );
  }
  return '{"data":{"countries":[$countries]}}';
}
