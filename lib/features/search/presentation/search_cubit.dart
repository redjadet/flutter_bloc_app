import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    required final SearchRepository repository,
    required final TimerService timerService,
    this.debounceDuration = const Duration(milliseconds: 500),
  }) : _repository = repository,
       _timerService = timerService,
       super(const SearchState());

  final SearchRepository _repository;
  final TimerService _timerService;
  final Duration debounceDuration;
  TimerDisposable? _debounceHandle;

  void search(final String query) {
    _cancelDebounce();

    emit(state.copyWith(query: query, clearError: true));

    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }

    _debounceHandle = _timerService.runOnce(
      debounceDuration,
      () => unawaited(_executeSearch(query)),
    );
  }

  void clearSearch() {
    _cancelDebounce();
    emit(const SearchState());
  }

  Future<void> _executeSearch(final String query) async {
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        query: query,
        clearError: true,
      ),
    );

    try {
      final results = await _repository.search(query);
      emit(
        state.copyWith(
          status: ViewStatus.success,
          query: query,
          results: List<SearchResult>.unmodifiable(results),
          clearError: true,
        ),
      );
    } on Exception catch (error) {
      emit(
        state.copyWith(status: ViewStatus.error, query: query, error: error),
      );
    }
  }

  void _cancelDebounce() {
    _debounceHandle?.dispose();
    _debounceHandle = null;
  }

  @override
  Future<void> close() {
    _cancelDebounce();
    return super.close();
  }
}
