import 'package:flutter_bloc_app/features/search/domain/search_cache_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/isolate_json.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive/hive.dart';

/// Hive-backed implementation of [SearchCacheRepository].
///
/// Persists recent search queries and their results locally so the search UI
/// can hydrate instantly and work offline.
class HiveSearchCacheRepository extends HiveRepositoryBase
    implements SearchCacheRepository {
  HiveSearchCacheRepository({required super.hiveService});

  static const String _boxName = 'search_cache';
  static const String _keyPrefix = 'query_';
  static const String _keyRecentQueries = 'recent_queries';
  static const int _maxRecentQueries = 50;

  @override
  String get boxName => _boxName;

  @override
  Future<List<SearchResult>?> loadCachedResults(final String query) async =>
      StorageGuard.run<List<SearchResult>?>(
        logContext: 'HiveSearchCacheRepository.loadCachedResults',
        action: () async {
          if (query.isEmpty) {
            return null;
          }
          final Box<dynamic> box = await getBox();
          final String key = '$_keyPrefix${_normalizeQuery(query)}';
          final dynamic raw = box.get(key);
          return _parseStored(raw);
        },
        fallback: () => null,
      );

  @override
  Future<void> saveCachedResults(
    final String query,
    final List<SearchResult> results,
  ) async => StorageGuard.run<void>(
    logContext: 'HiveSearchCacheRepository.saveCachedResults',
    action: () async {
      if (query.isEmpty) {
        return;
      }
      final Box<dynamic> box = await getBox();
      final String normalizedQuery = _normalizeQuery(query);
      final String key = '$_keyPrefix$normalizedQuery';

      final List<Map<String, dynamic>> serialized = results
          .map((final r) => r.toJson())
          .toList(growable: false);
      await box.put(key, serialized);

      await _addToRecentQueries(box, normalizedQuery);
    },
  );

  @override
  Future<List<String>> loadRecentQueries() async =>
      StorageGuard.run<List<String>>(
        logContext: 'HiveSearchCacheRepository.loadRecentQueries',
        action: () async {
          final Box<dynamic> box = await getBox();
          final dynamic raw = box.get(_keyRecentQueries);
          if (raw is List<dynamic>) {
            return raw
                .whereType<String>()
                .take(_maxRecentQueries)
                .toList(growable: false);
          }
          return const <String>[];
        },
        fallback: () => const <String>[],
      );

  @override
  Future<void> clearCache() async => StorageGuard.run<void>(
    logContext: 'HiveSearchCacheRepository.clearCache',
    action: () async {
      final Box<dynamic> box = await getBox();
      final List<String> keys = box.keys
          .whereType<String>()
          .where((final k) => k.startsWith(_keyPrefix))
          .toList(growable: false);
      for (final String key in keys) {
        await safeDeleteKey(box, key);
      }
      await safeDeleteKey(box, _keyRecentQueries);
    },
  );

  Future<void> _addToRecentQueries(
    final Box<dynamic> box,
    final String query,
  ) async {
    final dynamic raw = box.get(_keyRecentQueries);
    final List<String> recent =
        raw is List<dynamic>
              ? raw.whereType<String>().toList(growable: true)
              : <String>[]
          ..remove(query)
          ..insert(0, query);
    final List<String> trimmed = recent
        .take(_maxRecentQueries)
        .toList(growable: false);
    await box.put(_keyRecentQueries, trimmed);
  }

  Future<List<SearchResult>?> _parseStored(final dynamic raw) async {
    if (raw == null) {
      return null;
    }
    if (raw is String && raw.isNotEmpty) {
      try {
        final List<dynamic> decoded = await decodeJsonList(raw);
        return _parseIterable(decoded);
      } on Exception {
        return null;
      }
    }
    if (raw is Iterable<dynamic>) {
      return _parseIterable(raw);
    }
    return null;
  }

  List<SearchResult> _parseIterable(final Iterable<dynamic> raw) => raw
      .whereType<Map<dynamic, dynamic>>()
      .map(_mapToResult)
      .toList(growable: false);

  SearchResult _mapToResult(final Map<dynamic, dynamic> raw) {
    final Map<String, dynamic> normalized = raw.map(
      (final dynamic key, final dynamic value) =>
          MapEntry(key.toString(), value),
    );
    return SearchResult.fromJson(normalized);
  }

  String _normalizeQuery(final String query) => query.trim().toLowerCase();
}
