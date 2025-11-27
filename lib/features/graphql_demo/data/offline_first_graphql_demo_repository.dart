import 'package:flutter_bloc_app/features/graphql_demo/data/countries_graphql_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_demo_cache_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class OfflineFirstGraphqlDemoRepository implements GraphqlDemoRepository {
  OfflineFirstGraphqlDemoRepository({
    required this.remoteRepository,
    required this.cacheRepository,
  });
  static const Duration _maxCacheAge = Duration(hours: 24);
  GraphqlDataSource lastSource = GraphqlDataSource.unknown;

  final CountriesGraphqlRepository remoteRepository;
  final GraphqlDemoCacheRepository cacheRepository;

  @override
  Future<List<GraphqlContinent>> fetchContinents() async {
    final List<GraphqlContinent> cached = await cacheRepository.readContinents(
      maxAge: _maxCacheAge,
    );
    try {
      final List<GraphqlContinent> remote = await remoteRepository
          .fetchContinents();
      await cacheRepository.writeContinents(remote);
      lastSource = GraphqlDataSource.remote;
      _telemetry('remote');
      return remote;
    } on GraphqlDemoException {
      if (cached.isNotEmpty) {
        lastSource = GraphqlDataSource.cache;
        _telemetry('cache');
        return cached;
      }
      rethrow;
    } on Exception {
      if (cached.isNotEmpty) {
        lastSource = GraphqlDataSource.cache;
        _telemetry('cache');
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<List<GraphqlCountry>> fetchCountries({
    final String? continentCode,
  }) async {
    final List<GraphqlCountry> cached = await cacheRepository.readCountries(
      continentCode: continentCode,
      maxAge: _maxCacheAge,
    );
    try {
      final List<GraphqlCountry> remote = await remoteRepository.fetchCountries(
        continentCode: continentCode,
      );
      await cacheRepository.writeCountries(
        countries: remote,
        continentCode: continentCode,
      );
      lastSource = GraphqlDataSource.remote;
      _telemetry('remote', continentCode: continentCode);
      return remote;
    } on GraphqlDemoException {
      if (cached.isNotEmpty) {
        lastSource = GraphqlDataSource.cache;
        _telemetry('cache', continentCode: continentCode);
        return cached;
      }
      rethrow;
    } on Exception {
      if (cached.isNotEmpty) {
        lastSource = GraphqlDataSource.cache;
        _telemetry('cache', continentCode: continentCode);
        return cached;
      }
      rethrow;
    }
  }

  void _telemetry(
    final String source, {
    final String? continentCode,
  }) {
    final String details = [
      'source=$source',
      if (continentCode != null) 'continent=$continentCode',
    ].join(' ');
    AppLogger.info('GraphQL demo fetch $details');
  }
}
