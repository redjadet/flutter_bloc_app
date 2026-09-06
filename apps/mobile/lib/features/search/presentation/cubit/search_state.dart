import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.freezed.dart';

@freezed
abstract class SearchState with _$SearchState {
  const factory({
    @Default(ViewStatus.initial) ViewStatus status,
    @Default('') String query,
    @Default(<SearchResult>[]) List<SearchResult> results,
    Object? error,
  }) = _SearchState;

  const new _();

  /// Convenience getters for status and results.
  bool get isLoading => status.isLoading;
  bool get hasResults => results.isNotEmpty;
}
