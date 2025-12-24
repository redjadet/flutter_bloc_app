import 'package:flutter_bloc_app/features/search/domain/search_result.dart';

abstract class SearchRepository {
  const SearchRepository();

  Future<List<SearchResult>> search(final String query);

  Future<List<SearchResult>> call(final String query) => search(query);
}
