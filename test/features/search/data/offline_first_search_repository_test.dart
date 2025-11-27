import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc_app/features/search/data/offline_first_search_repository.dart';
import 'package:flutter_bloc_app/features/search/data/search_cache_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _FakeRemoteRepository implements SearchRepository {
  _FakeRemoteRepository();

  bool shouldFail = false;
  final List<String> calledQueries = <String>[];

  @override
  Future<List<SearchResult>> search(final String query) async {
    calledQueries.add(query);
    if (shouldFail) {
      throw Exception('network error');
    }
    return <SearchResult>[
      SearchResult(
        id: 'remote_$query',
        imageUrl: 'https://example.com/$query.jpg',
      ),
    ];
  }

  @override
  Future<List<SearchResult>> call(final String query) => search(query);
}

class _FakeNetworkStatusService implements NetworkStatusService {
  _FakeNetworkStatusService();

  bool isOnline = true;
  final StreamController<NetworkStatus> _controller =
      StreamController<NetworkStatus>.broadcast();

  @override
  Stream<NetworkStatus> get statusStream => _controller.stream;

  @override
  Future<NetworkStatus> getCurrentStatus() async =>
      isOnline ? NetworkStatus.online : NetworkStatus.offline;

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  void emit(final NetworkStatus status) {
    _controller.add(status);
  }
}

void main() {
  group('OfflineFirstSearchRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late SearchCacheRepository cacheRepository;
    late PendingSyncRepository pendingRepository;
    late SyncableRepositoryRegistry registry;
    late _FakeRemoteRepository remoteRepository;
    late _FakeNetworkStatusService networkService;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('offline_search_repo_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      cacheRepository = SearchCacheRepository(hiveService: hiveService);
      pendingRepository = PendingSyncRepository(hiveService: hiveService);
      registry = SyncableRepositoryRegistry();
      remoteRepository = _FakeRemoteRepository();
      networkService = _FakeNetworkStatusService();
    });

    tearDown(() async {
      await pendingRepository.clear();
      await networkService.dispose();
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    OfflineFirstSearchRepository buildRepository() =>
        OfflineFirstSearchRepository(
          remoteRepository: remoteRepository,
          cacheRepository: cacheRepository,
          networkStatusService: networkService,
          registry: registry,
        );

    test('search returns empty list for empty query', () async {
      final OfflineFirstSearchRepository repository = buildRepository();
      final List<SearchResult> results = await repository.search('');
      expect(results, isEmpty);
      expect(remoteRepository.calledQueries, isEmpty);
    });

    test('search fetches and caches when cache miss and online', () async {
      networkService.isOnline = true;
      final OfflineFirstSearchRepository repository = buildRepository();

      final List<SearchResult> results = await repository.search('dogs');

      expect(results.length, 1);
      expect(results.first.id, 'remote_dogs');
      expect(remoteRepository.calledQueries, contains('dogs'));

      // Verify cached
      final List<SearchResult>? cached = await cacheRepository
          .loadCachedResults('dogs');
      expect(cached, isNotNull);
      expect(cached!.first.id, 'remote_dogs');
    });

    test('search serves from cache when offline', () async {
      networkService.isOnline = false;
      final OfflineFirstSearchRepository repository = buildRepository();

      // Pre-populate cache
      const List<SearchResult> cachedResults = [
        SearchResult(
          id: 'cached_1',
          imageUrl: 'https://example.com/cached.jpg',
        ),
      ];
      await cacheRepository.saveCachedResults('dogs', cachedResults);

      final List<SearchResult> results = await repository.search('dogs');

      expect(results.length, 1);
      expect(results.first.id, 'cached_1');
      expect(remoteRepository.calledQueries, isEmpty);
    });

    test(
      'search returns cached immediately and refreshes in background when online',
      () async {
        networkService.isOnline = true;
        final OfflineFirstSearchRepository repository = buildRepository();

        // Pre-populate cache
        const List<SearchResult> cachedResults = [
          SearchResult(
            id: 'cached_1',
            imageUrl: 'https://example.com/cached.jpg',
          ),
        ];
        await cacheRepository.saveCachedResults('dogs', cachedResults);

        final List<SearchResult> results = await repository.search('dogs');

        // Should return cached immediately
        expect(results.length, 1);
        expect(results.first.id, 'cached_1');

        // Wait for background refresh
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Verify remote was called for refresh
        expect(remoteRepository.calledQueries, contains('dogs'));

        // Verify cache was updated
        final List<SearchResult>? updatedCache = await cacheRepository
            .loadCachedResults('dogs');
        expect(updatedCache, isNotNull);
        expect(updatedCache!.first.id, 'remote_dogs');
      },
    );

    test('search returns empty when cache miss and offline', () async {
      networkService.isOnline = false;
      final OfflineFirstSearchRepository repository = buildRepository();

      final List<SearchResult> results = await repository.search('dogs');

      expect(results, isEmpty);
      expect(remoteRepository.calledQueries, isEmpty);
    });

    test('search falls back to cache when remote fails', () async {
      networkService.isOnline = true;
      remoteRepository.shouldFail = true;
      final OfflineFirstSearchRepository repository = buildRepository();

      // Pre-populate cache
      const List<SearchResult> cachedResults = [
        SearchResult(
          id: 'cached_1',
          imageUrl: 'https://example.com/cached.jpg',
        ),
      ];
      await cacheRepository.saveCachedResults('dogs', cachedResults);

      final List<SearchResult> results = await repository.search('dogs');

      // Should return cached results even though remote failed
      expect(results.length, 1);
      expect(results.first.id, 'cached_1');
    });

    test('search throws when remote fails and no cache exists', () async {
      networkService.isOnline = true;
      remoteRepository.shouldFail = true;
      final OfflineFirstSearchRepository repository = buildRepository();

      expect(() => repository.search('dogs'), throwsA(isA<Exception>()));
    });

    test('processOperation is no-op for search entity', () async {
      final OfflineFirstSearchRepository repository = buildRepository();
      final SyncOperation operation = SyncOperation.create(
        entityType: 'search',
        payload: const <String, dynamic>{'query': 'test'},
        idempotencyKey: 'test-key',
      );

      // Should not throw
      await repository.processOperation(operation);
    });

    test('pullRemote refreshes recent queries when online', () async {
      networkService.isOnline = true;
      final OfflineFirstSearchRepository repository = buildRepository();

      // Pre-populate cache with multiple queries
      const List<SearchResult> results = [
        SearchResult(id: '1', imageUrl: 'https://example.com/1.jpg'),
      ];
      await cacheRepository.saveCachedResults('dogs', results);
      await cacheRepository.saveCachedResults('cats', results);
      await cacheRepository.saveCachedResults('birds', results);

      await repository.pullRemote();

      // Should have called remote for top queries (up to 10)
      expect(remoteRepository.calledQueries.length, 3);
      expect(remoteRepository.calledQueries, contains('birds'));
      expect(remoteRepository.calledQueries, contains('cats'));
      expect(remoteRepository.calledQueries, contains('dogs'));
    });

    test('pullRemote does nothing when offline', () async {
      networkService.isOnline = false;
      final OfflineFirstSearchRepository repository = buildRepository();

      // Pre-populate cache
      const List<SearchResult> results = [
        SearchResult(id: '1', imageUrl: 'https://example.com/1.jpg'),
      ];
      await cacheRepository.saveCachedResults('dogs', results);

      await repository.pullRemote();

      expect(remoteRepository.calledQueries, isEmpty);
    });

    test('pullRemote limits refresh to top 10 queries', () async {
      networkService.isOnline = true;
      final OfflineFirstSearchRepository repository = buildRepository();

      // Pre-populate cache with 15 queries
      const List<SearchResult> results = [
        SearchResult(id: '1', imageUrl: 'https://example.com/1.jpg'),
      ];
      for (int i = 0; i < 15; i++) {
        await cacheRepository.saveCachedResults('query$i', results);
      }

      await repository.pullRemote();

      // Should only refresh top 10
      expect(remoteRepository.calledQueries.length, 10);
    });

    test('entityType returns search', () {
      final OfflineFirstSearchRepository repository = buildRepository();
      expect(repository.entityType, 'search');
    });

    test('registers itself in SyncableRepositoryRegistry', () {
      final SyncableRepositoryRegistry testRegistry =
          SyncableRepositoryRegistry();
      final OfflineFirstSearchRepository repository =
          OfflineFirstSearchRepository(
            remoteRepository: remoteRepository,
            cacheRepository: cacheRepository,
            networkStatusService: networkService,
            registry: testRegistry,
          );

      expect(testRegistry.resolve('search'), isNotNull);
      expect(testRegistry.resolve('search'), equals(repository));
    });
  });
}
