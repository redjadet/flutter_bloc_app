import 'package:flutter_bloc_app/features/search/domain/search_result.dart';

/// Repository contract for search: runs a query and returns a list of results.
abstract class SearchRepository {
  const SearchRepository();

  /// Returns search results for the given [query].
  Future<List<SearchResult>> search(final String query);

  /// Convenience callable that delegates to [search].
  Future<List<SearchResult>> call(final String query) => search(query);
}
