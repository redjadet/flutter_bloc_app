import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_remote_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class AuthAwareGraphqlRemoteRepository implements GraphqlRemoteRepository {
  AuthAwareGraphqlRemoteRepository({
    required final GraphqlRemoteRepository supabaseRemote,
    required final GraphqlRemoteRepository directRemote,
    required final bool Function() isSupabaseSignedIn,
  }) : _supabaseRemote = supabaseRemote,
       _directRemote = directRemote,
       _isSupabaseSignedIn = isSupabaseSignedIn;

  final GraphqlRemoteRepository _supabaseRemote;
  final GraphqlRemoteRepository _directRemote;
  final bool Function() _isSupabaseSignedIn;
  GraphqlDataSource _lastSource = GraphqlDataSource.unknown;

  GraphqlRemoteRepository get _active {
    try {
      return _isSupabaseSignedIn() ? _supabaseRemote : _directRemote;
    } on Object catch (e, s) {
      AppLogger.warning(
        'AuthAwareGraphqlRemoteRepository isSupabaseSignedIn failed, '
        'using direct remote',
      );
      AppLogger.error(
        'AuthAwareGraphqlRemoteRepository._active',
        e,
        s,
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
