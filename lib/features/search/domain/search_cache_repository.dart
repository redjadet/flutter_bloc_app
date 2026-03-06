import 'package:flutter_bloc_app/features/search/domain/search_result.dart';

/// Abstraction for caching search results and recent queries.
///
/// Implementations may use local storage (e.g. Hive) so the search UI
/// can hydrate instantly and work offline.
abstract class SearchCacheRepository {
  /// Loads cached results for a query, or null if not cached.
  Future<List<SearchResult>?> loadCachedResults(final String query);

  /// Saves search results for a query.
  Future<void> saveCachedResults(
    final String query,
    final List<SearchResult> results,
  );

  /// Loads recent search queries (most recent first).
  Future<List<String>> loadRecentQueries();

  /// Clears all cached search results.
  Future<void> clearCache();
}
