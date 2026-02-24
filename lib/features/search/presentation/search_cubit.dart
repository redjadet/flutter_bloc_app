import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

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
  int _searchRequestId = 0;

  void search(final String query) {
    _cancelDebounce();
    final int requestId = _nextSearchRequestId();

    emit(state.copyWith(query: query, error: null));

    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }

    _debounceHandle = _timerService.runOnce(
      debounceDuration,
      () => unawaited(_executeSearch(query, requestId)),
    );
  }

  void clearSearch() {
    _cancelDebounce();
    _nextSearchRequestId(); // Invalidate any pending search requests
    emit(const SearchState());
  }

  Future<void> _executeSearch(
    final String query,
    final int requestId,
  ) async {
    if (!_isRequestActive(requestId, query)) {
      return;
    }
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        query: query,
        error: null,
      ),
    );

    await CubitExceptionHandler.executeAsync(
      operation: () => _repository.search(query),
      isAlive: () => !isClosed,
      onSuccess: (final results) {
        if (!_isRequestActive(requestId, query)) return;
        emit(
          state.copyWith(
            status: ViewStatus.success,
            query: query,
            results: List<SearchResult>.unmodifiable(results),
            error: null,
          ),
        );
      },
      onError: (final errorMessage) {
        if (!_isRequestActive(requestId, query)) return;
        emit(
          state.copyWith(
            status: ViewStatus.error,
            query: query,
            error: Exception(errorMessage),
          ),
        );
      },
      logContext: 'SearchCubit._executeSearch',
    );
  }

  void _cancelDebounce() {
    _debounceHandle?.dispose();
    _debounceHandle = null;
  }

  int _nextSearchRequestId() => ++_searchRequestId;

  bool _isRequestActive(final int requestId, final String query) =>
      !isClosed && requestId == _searchRequestId && state.query == query;

  @override
  Future<void> close() {
    _cancelDebounce();
    return super.close();
  }
}
