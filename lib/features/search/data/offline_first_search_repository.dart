import 'dart:async';

import 'package:flutter_bloc_app/features/search/data/search_cache_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Offline-first implementation of [SearchRepository].
///
/// Caches search results locally and serves from cache when offline.
/// Implements [SyncableRepository] to allow background refresh of cached results.
class OfflineFirstSearchRepository
    implements SearchRepository, SyncableRepository {
  OfflineFirstSearchRepository({
    required SearchRepository remoteRepository,
    required SearchCacheRepository cacheRepository,
    required NetworkStatusService networkStatusService,
    required SyncableRepositoryRegistry registry,
  }) : _remoteRepository = remoteRepository,
       _cacheRepository = cacheRepository,
       _networkStatusService = networkStatusService,
       _registry = registry {
    _registry.register(this);
  }

  static const String searchEntity = 'search';

  final SearchRepository _remoteRepository;
  final SearchCacheRepository _cacheRepository;
  final NetworkStatusService _networkStatusService;
  final SyncableRepositoryRegistry _registry;

  @override
  String get entityType => searchEntity;

  @override
  Future<List<SearchResult>> search(final String query) async {
    if (query.isEmpty) {
      return const <SearchResult>[];
    }

    // Always check cache first
    final List<SearchResult>? cached = await _cacheRepository.loadCachedResults(
      query,
    );
    final NetworkStatus networkStatus = await _networkStatusService
        .getCurrentStatus();
    final bool isOnline = networkStatus == NetworkStatus.online;

    if (cached != null && cached.isNotEmpty) {
      // If we have cached results and we're offline, return them immediately
      if (!isOnline) {
        AppLogger.info(
          'OfflineFirstSearchRepository.search: serving from cache (offline)',
        );
        return cached;
      }

      // If online, fetch fresh results in background but return cached immediately
      // This provides instant UI while refreshing data
      unawaited(_refreshAndCache(query));
      return cached;
    }

    // No cache hit - try remote if online
    if (isOnline) {
      try {
        final List<SearchResult> results = await _remoteRepository.search(
          query,
        );
        await _cacheRepository.saveCachedResults(query, results);
        return results;
      } on Exception catch (error, stackTrace) {
        AppLogger.error(
          'OfflineFirstSearchRepository.search failed',
          error,
          stackTrace,
        );
        // If remote fails but we have any cached results, return them
        if (cached != null) {
          return cached;
        }
        rethrow;
      }
    }

    // Offline and no cache - return empty
    AppLogger.info('OfflineFirstSearchRepository.search: no cache, offline');
    return const <SearchResult>[];
  }

  @override
  Future<List<SearchResult>> call(final String query) => search(query);

  /// Refreshes cached results for a query in the background.
  Future<void> _refreshAndCache(final String query) async {
    try {
      final List<SearchResult> results = await _remoteRepository.search(query);
      await _cacheRepository.saveCachedResults(query, results);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'OfflineFirstSearchRepository._refreshAndCache failed',
        error,
        stackTrace,
      );
    }
  }

  @override
  Future<void> processOperation(final SyncOperation operation) async {
    // Search doesn't queue mutations, but we could use this for future features
    // like "save search" or "favorite result" operations
    AppLogger.info(
      'OfflineFirstSearchRepository.processOperation: no-op for search entity',
    );
  }

  @override
  Future<void> pullRemote() async {
    // Refresh recent queries' cached results when online
    final NetworkStatus networkStatus = await _networkStatusService
        .getCurrentStatus();
    if (networkStatus != NetworkStatus.online) {
      return;
    }

    try {
      final List<String> recentQueries = await _cacheRepository
          .loadRecentQueries();
      // Refresh top 10 most recent queries
      for (final String query in recentQueries.take(10)) {
        await _refreshAndCache(query);
      }
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'OfflineFirstSearchRepository.pullRemote failed',
        error,
        stackTrace,
      );
    }
  }
}
