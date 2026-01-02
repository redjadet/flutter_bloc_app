import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.freezed.dart';

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @Default(ViewStatus.initial) final ViewStatus status,
    @Default('') final String query,
    @Default(<SearchResult>[]) final List<SearchResult> results,
    final Object? error,
  }) = _SearchState;

  const SearchState._();

  // Custom getters (preserved from original)
  bool get isLoading => status.isLoading;
  bool get hasResults => results.isNotEmpty;
}
