import 'dart:io';

import 'package:flutter_bloc_app/features/search/data/search_cache_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('SearchCacheRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late SearchCacheRepository repository;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('search_cache_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      repository = SearchCacheRepository(hiveService: hiveService);
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('loadCachedResults returns null for empty query', () async {
      final List<SearchResult>? result = await repository.loadCachedResults('');
      expect(result, isNull);
    });

    test('loadCachedResults returns null when no cache exists', () async {
      final List<SearchResult>? result = await repository.loadCachedResults(
        'dogs',
      );
      expect(result, isNull);
    });

    test(
      'saveCachedResults and loadCachedResults round-trip correctly',
      () async {
        const List<SearchResult> results = [
          SearchResult(
            id: '1',
            imageUrl: 'https://example.com/1.jpg',
            title: 'Dog 1',
            description: 'Description 1',
          ),
          SearchResult(
            id: '2',
            imageUrl: 'https://example.com/2.jpg',
            title: 'Dog 2',
          ),
        ];

        await repository.saveCachedResults('dogs', results);
        final List<SearchResult>? loaded = await repository.loadCachedResults(
          'dogs',
        );

        expect(loaded, isNotNull);
        expect(loaded!.length, 2);
        expect(loaded[0].id, '1');
        expect(loaded[0].title, 'Dog 1');
        expect(loaded[0].description, 'Description 1');
        expect(loaded[1].id, '2');
        expect(loaded[1].title, 'Dog 2');
      },
    );

    test('saveCachedResults normalizes query (lowercase, trimmed)', () async {
      const List<SearchResult> results = [
        SearchResult(id: '1', imageUrl: 'https://example.com/1.jpg'),
      ];

      await repository.saveCachedResults('  DOGS  ', results);
      final List<SearchResult>? loaded1 = await repository.loadCachedResults(
        'dogs',
      );
      final List<SearchResult>? loaded2 = await repository.loadCachedResults(
        '  DOGS  ',
      );

      expect(loaded1, isNotNull);
      expect(loaded2, isNotNull);
      expect(loaded1!.length, loaded2!.length);
    });

    test('saveCachedResults ignores empty query', () async {
      const List<SearchResult> results = [
        SearchResult(id: '1', imageUrl: 'https://example.com/1.jpg'),
      ];

      await repository.saveCachedResults('', results);
      final List<SearchResult>? loaded = await repository.loadCachedResults('');
      expect(loaded, isNull);
    });

    test('loadRecentQueries returns empty list initially', () async {
      final List<String> recent = await repository.loadRecentQueries();
      expect(recent, isEmpty);
    });

    test(
      'loadRecentQueries returns queries in most-recent-first order',
      () async {
        const List<SearchResult> results = [
          SearchResult(id: '1', imageUrl: 'https://example.com/1.jpg'),
        ];

        await repository.saveCachedResults('dogs', results);
        await repository.saveCachedResults('cats', results);
        await repository.saveCachedResults('birds', results);

        final List<String> recent = await repository.loadRecentQueries();
        expect(recent.length, 3);
        expect(recent[0], 'birds');
        expect(recent[1], 'cats');
        expect(recent[2], 'dogs');
      },
    );

    test('loadRecentQueries limits to 50 most recent queries', () async {
      const List<SearchResult> results = [
        SearchResult(id: '1', imageUrl: 'https://example.com/1.jpg'),
      ];

      for (int i = 0; i < 60; i++) {
        await repository.saveCachedResults('query$i', results);
      }

      final List<String> recent = await repository.loadRecentQueries();
      expect(recent.length, 50);
      expect(recent.first, 'query59');
      expect(recent.last, 'query10');
    });

    test('loadRecentQueries removes duplicates and moves to front', () async {
      const List<SearchResult> results = [
        SearchResult(id: '1', imageUrl: 'https://example.com/1.jpg'),
      ];

      await repository.saveCachedResults('dogs', results);
      await repository.saveCachedResults('cats', results);
      await repository.saveCachedResults('dogs', results); // Duplicate

      final List<String> recent = await repository.loadRecentQueries();
      expect(recent.length, 2);
      expect(recent[0], 'dogs');
      expect(recent[1], 'cats');
    });

    test('clearCache removes all cached results and recent queries', () async {
      const List<SearchResult> results = [
        SearchResult(id: '1', imageUrl: 'https://example.com/1.jpg'),
      ];

      await repository.saveCachedResults('dogs', results);
      await repository.saveCachedResults('cats', results);

      expect(await repository.loadCachedResults('dogs'), isNotNull);
      expect(await repository.loadRecentQueries(), isNotEmpty);

      await repository.clearCache();

      expect(await repository.loadCachedResults('dogs'), isNull);
      expect(await repository.loadCachedResults('cats'), isNull);
      expect(await repository.loadRecentQueries(), isEmpty);
    });
  });
}
