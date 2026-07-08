import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_remote_repository.dart';

class AuthAwareGraphqlRemoteRepository implements GraphqlRemoteRepository {
  AuthAwareGraphqlRemoteRepository({
    required this._supabaseRemote,
    required this._directRemote,
    required this._isSupabaseSignedIn,
  });

  final GraphqlRemoteRepository _supabaseRemote;
  final GraphqlRemoteRepository _directRemote;
  final bool Function() _isSupabaseSignedIn;
  GraphqlDataSource _lastSource = GraphqlDataSource.unknown;

  GraphqlRemoteRepository get _active {
    try {
      return _isSupabaseSignedIn() ? _supabaseRemote : _directRemote;
    } on Object catch (error, stackTrace) {
      AppLogger.warning(
        'AuthAwareGraphqlRemoteRepository isSupabaseSignedIn failed, '
        'using direct remote',
      );
      AppLogger.error(
        'AuthAwareGraphqlRemoteRepository._active',
        error,
        stackTrace,
      );
      return _directRemote;
    }
  }

  @override
  GraphqlDataSource get lastSource => _lastSource;

  @override
  Future<List<GraphqlContinent>> fetchContinents() async {
    final GraphqlRemoteRepository active = _active;
    final List<GraphqlContinent> continents = await active.fetchContinents();
    _lastSource = active.lastSource;
    return continents;
  }

  @override
  Future<List<GraphqlCountry>> fetchCountries({
    final String? continentCode,
  }) async {
    final GraphqlRemoteRepository active = _active;
    final List<GraphqlCountry> countries = await active.fetchCountries(
      continentCode: continentCode,
    );
    _lastSource = active.lastSource;
    return countries;
  }
}
