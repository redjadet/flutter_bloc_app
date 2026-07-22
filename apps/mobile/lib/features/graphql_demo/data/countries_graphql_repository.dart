import 'dart:convert';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/api/countries_graphql_api.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_country_dto.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_remote_repository.dart';
import 'package:ilkersevim_json_isolate/ilkersevim_json_isolate.dart';
import 'package:networking/networking.dart';
import 'package:utilities/utilities.dart';

part 'countries_graphql_repository_queries.part.dart';

/// GraphQL-backed repository that talks to https://countries.trevorblades.com.
///
/// Uses [CountriesGraphqlApi] (Retrofit) for operation-specific POST calls.
/// [Dio] instances are injected via `get_it` so DI can dispose them
/// when the app shuts down.
class CountriesGraphqlRepository
    implements GraphqlDemoRepository, GraphqlRemoteRepository {
  CountriesGraphqlRepository({required final Dio client})
    : this._fromClient(client);

  CountriesGraphqlRepository._fromClient(final Dio client)
    : _api = CountriesGraphqlApi(client);

  static const String _opContinents = 'Continents';
  static const String _opAllCountries = 'AllCountries';
  static const String _opCountriesByContinent = 'CountriesByContinent';
  final CountriesGraphqlApi _api;

  static Options options() => Options(
    contentType: 'application/json',
    headers: const <String, String>{'Content-Type': 'application/json'},
  );

  @override
  GraphqlDataSource get lastSource => GraphqlDataSource.remote;

  @override
  Future<List<GraphqlContinent>> fetchContinents() async {
    final Map<String, dynamic> data = await postQuery(
      _CountriesGraphqlRepositoryQueries.continentsQuery,
      operationName: _opContinents,
    );
    return mapContinents(data['continents']);
  }

  @override
  Future<List<GraphqlCountry>> fetchCountries({
    final String? continentCode,
  }) async {
    final String? normalizedCode = normalizedContinentCode(continentCode);
    if (normalizedCode == null) {
      final Map<String, dynamic> data = await postQuery(
        _CountriesGraphqlRepositoryQueries.allCountriesQuery,
        operationName: _opAllCountries,
      );
      return mapCountries(data['countries']);
    }

    final Map<String, dynamic> data = await postQuery(
      _CountriesGraphqlRepositoryQueries.countriesByContinentQuery,
      variables: <String, dynamic>{'continent': normalizedCode},
      operationName: _opCountriesByContinent,
    );
    final Map<String, dynamic>? continent = mapFromDynamic(data['continent']);
    return mapCountries(continent?['countries']);
  }
}
