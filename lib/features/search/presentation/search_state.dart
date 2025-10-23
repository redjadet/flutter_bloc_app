import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';

enum SearchStatus { initial, loading, success, error }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.results = const [],
    this.error,
  });

  final SearchStatus status;
  final String query;
  final List<SearchResult> results;
  final Object? error;

  bool get isLoading => status == SearchStatus.loading;
  bool get hasResults => results.isNotEmpty;

  SearchState copyWith({
    final SearchStatus? status,
    final String? query,
    final List<SearchResult>? results,
    final Object? error,
    final bool clearError = false,
  }) => SearchState(
    status: status ?? this.status,
    query: query ?? this.query,
    results: results != null
        ? List<SearchResult>.unmodifiable(results)
        : this.results,
    error: clearError ? null : error ?? this.error,
  );

  @override
  List<Object?> get props => [status, query, results, error];
}
