import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ilkersevim_async_utils/ilkersevim_async_utils.dart';
import 'package:utilities/utilities.dart';

part 'chart_cubit.freezed.dart';
part 'chart_state.dart';

/// Explicit chart load workflows (avoids a boolean that hides fetch strategy).
enum ChartFetchMode {
  /// Drop points and call [ChartRepository.fetchTrendingCounts].
  clearThenFetch,

  /// Keep stale points and call [ChartRepository.refreshTrendingCounts].
  keepStaleRefresh,
}

class ChartCubit extends Cubit<ChartState> {
  new({required this._repository}) : super(const ChartState());

  final ChartRepository _repository;
  final RequestIdGuard _fetchGuard = RequestIdGuard();

  Future<void> load() async {
    if (isClosed) {
      return;
    }
    if (state.status.isLoading) {
      return;
    }
    List<ChartPoint> cached =
        _repository.getCachedTrendingCounts() ?? const <ChartPoint>[];
    if (cached.isEmpty) {
      cached = await _repository.loadCachedTrendingCounts();
      if (isClosed) {
        return;
      }
    }
    if (cached.isNotEmpty && !isClosed) {
      emit(
        state.copyWith(
          status: ViewStatus.success,
          points: cached,
          dataSource: ChartDataSource.cache,
        ),
      );
    }
    await _fetch(
      cached.isEmpty
          ? ChartFetchMode.clearThenFetch
          : ChartFetchMode.keepStaleRefresh,
    );
  }

  Future<void> refresh() async {
    if (isClosed) {
      return;
    }
    await _fetch(ChartFetchMode.keepStaleRefresh);
  }

  void setZoomEnabled({required bool isEnabled}) {
    if (isClosed) {
      return;
    }
    if (state.zoomEnabled == isEnabled) {
      return;
    }
    emit(state.copyWith(zoomEnabled: isEnabled));
  }

  Future<void> _fetch(ChartFetchMode mode) async {
    if (isClosed) {
      return;
    }
    final int requestId = _fetchGuard.next();
    final bool clearExisting = mode == ChartFetchMode.clearThenFetch;

    emit(
      state.copyWith(
        status: ViewStatus.loading,
        errorMessage: null,
        points: clearExisting ? const <ChartPoint>[] : state.points,
      ),
    );

    await CubitExceptionHandler.executeAsync(
      operation: clearExisting
          ? _repository.fetchTrendingCounts
          : _repository.refreshTrendingCounts,
      isAlive: () => !isClosed,
      onSuccess: (points) {
        if (isClosed || !_fetchGuard.isCurrent(requestId)) return;
        emit(
          state.copyWith(
            status: ViewStatus.success,
            points: points.isEmpty ? const <ChartPoint>[] : points,
            dataSource: _repository.lastSource,
          ),
        );
      },
      onError: (_) {},
      onFailure: (failure) {
        if (isClosed || !_fetchGuard.isCurrent(requestId)) return;
        emit(
          state.copyWith(
            status: ViewStatus.error,
            errorMessage: failure.message,
            points: state.points,
            dataSource: ChartDataSource.unknown,
            lastError: failure.appError,
          ),
        );
      },
      logContext: 'ChartCubit._fetch',
    );
  }
}
