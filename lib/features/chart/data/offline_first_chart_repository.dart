import 'package:flutter_bloc_app/features/chart/domain/chart_cache_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class OfflineFirstChartRepository extends ChartRepository {
  OfflineFirstChartRepository({
    required final ChartRemoteRepository remoteRepository,
    required final ChartCacheRepository cacheRepository,
  }) : _remoteRepository = remoteRepository,
       _cacheRepository = cacheRepository;

  static const Duration _maxCacheAge = Duration(hours: 24);
  static const String _logContext =
      'OfflineFirstChartRepository.fetchTrendingCounts';

  final ChartRemoteRepository _remoteRepository;
  final ChartCacheRepository _cacheRepository;

  List<ChartPoint>? _lastCached;

  @override
  ChartDataSource get lastSource => _lastSource;
  ChartDataSource _lastSource = ChartDataSource.unknown;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    final List<ChartPoint> cached = await _cacheRepository.readTrendingCounts(
      maxAge: _maxCacheAge,
    );
    if (cached.isNotEmpty) {
      _lastCached = cached;
      _lastSource = ChartDataSource.cache;
      AppLogger.info('Chart fetch source=cache');
      return cached;
    }

    return _fetchRemoteAndCache(
      cachedFallback: cached,
      allowCacheFallback: false,
    );
  }

  @override
  Future<List<ChartPoint>> refreshTrendingCounts() async {
    final List<ChartPoint> cached = await _cacheRepository.readTrendingCounts(
      maxAge: _maxCacheAge,
    );
    if (cached.isNotEmpty) {
      _lastCached = cached;
    }

    return _fetchRemoteAndCache(
      cachedFallback: cached,
      allowCacheFallback: true,
    );
  }

  Future<List<ChartPoint>> _fetchRemoteAndCache({
    required final List<ChartPoint> cachedFallback,
    required final bool allowCacheFallback,
  }) async {
    try {
      final List<ChartPoint> remote = await _remoteRepository
          .fetchTrendingCounts();
      try {
        await _cacheRepository.writeTrendingCounts(remote);
      } on Object catch (e, s) {
        AppLogger.error(
          'OfflineFirstChartRepository write cache failed',
          e,
          s,
        );
      }
      _lastCached = remote;
      _lastSource = _remoteRepository.lastSource;
      AppLogger.info('Chart fetch source=${_lastSource.name}');
      return remote;
    } on Exception catch (e, s) {
      AppLogger.error(_logContext, e, s);
      if (allowCacheFallback && cachedFallback.isNotEmpty) {
        _lastSource = ChartDataSource.cache;
        AppLogger.info('Chart fetch source=cache (fallback)');
        return cachedFallback;
      }
      _lastSource = ChartDataSource.unknown;
      rethrow;
    } on Object catch (e, s) {
      AppLogger.error(_logContext, e, s);
      if (allowCacheFallback && cachedFallback.isNotEmpty) {
        _lastSource = ChartDataSource.cache;
        AppLogger.info('Chart fetch source=cache (fallback)');
        return cachedFallback;
      }
      _lastSource = ChartDataSource.unknown;
      rethrow;
    }
  }

  @override
  List<ChartPoint>? getCachedTrendingCounts() => _lastCached;

  @override
  Future<List<ChartPoint>> call() => fetchTrendingCounts();
}
