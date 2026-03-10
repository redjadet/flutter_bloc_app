import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_remote_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class OfflineFirstGraphqlDemoRepository implements GraphqlDemoRepository {
  OfflineFirstGraphqlDemoRepository({
    required this.remoteRepository,
    required this.cacheRepository,
  });
  static const Duration _maxCacheAge = Duration(hours: 24);
  static const String _logContextFetchContinents =
      'OfflineFirstGraphqlDemoRepository.fetchContinents';
  static const String _logContextFetchCountries =
      'OfflineFirstGraphqlDemoRepository.fetchCountries';

  @override
  GraphqlDataSource lastSource = GraphqlDataSource.unknown;

  final GraphqlRemoteRepository remoteRepository;
  final GraphqlCacheRepository cacheRepository;

  @override
  Future<List<GraphqlContinent>> fetchContinents() async {
    return _fetchWithCache<GraphqlContinent>(
      logContext: _logContextFetchContinents,
      readCache: () => cacheRepository.readContinents(maxAge: _maxCacheAge),
      fetchRemote: remoteRepository.fetchContinents,
      writeCache: cacheRepository.writeContinents,
      continentCodeForTelemetry: null,
    );
  }

  @override
  Future<List<GraphqlCountry>> fetchCountries({
    final String? continentCode,
  }) async {
    return _fetchWithCache<GraphqlCountry>(
      logContext: _logContextFetchCountries,
      readCache: () => cacheRepository.readCountries(
        continentCode: continentCode,
        maxAge: _maxCacheAge,
      ),
      fetchRemote: () => remoteRepository.fetchCountries(
        continentCode: continentCode,
      ),
      writeCache: (final countries) => cacheRepository.writeCountries(
        countries: countries,
        continentCode: continentCode,
      ),
      continentCodeForTelemetry: continentCode,
    );
  }

  Future<List<T>> _fetchWithCache<T>({
    required final String logContext,
    required final Future<List<T>> Function() readCache,
    required final Future<List<T>> Function() fetchRemote,
    required final Future<void> Function(List<T> items) writeCache,
    required final String? continentCodeForTelemetry,
  }) async {
    final List<T> cached = await readCache();
    try {
      final List<T> remote = await fetchRemote();
      await writeCache(remote);
      lastSource = remoteRepository.lastSource;
      _telemetry('remote', continentCode: continentCodeForTelemetry);
      return remote;
    } on GraphqlDemoException catch (e, s) {
      AppLogger.error(logContext, e, s);
      if (cached.isNotEmpty) {
        lastSource = GraphqlDataSource.cache;
        _telemetry('cache', continentCode: continentCodeForTelemetry);
        return cached;
      }
      rethrow;
    } on Exception catch (e, s) {
      AppLogger.error(logContext, e, s);
      if (cached.isNotEmpty) {
        lastSource = GraphqlDataSource.cache;
        _telemetry('cache', continentCode: continentCodeForTelemetry);
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
