import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/app_error.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/network_error_mapper.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chart_cubit.freezed.dart';
part 'chart_state.dart';

class ChartCubit extends Cubit<ChartState> {
  ChartCubit({required final ChartRepository repository})
    : _repository = repository,
      super(const ChartState());

  final ChartRepository _repository;
  int _fetchRequestId = 0;

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
    await _fetch(resetExistingData: cached.isEmpty);
  }

  Future<void> refresh() async {
    if (isClosed) {
      return;
    }
    await _fetch(resetExistingData: false);
  }

  void setZoomEnabled({required final bool isEnabled}) {
    if (isClosed) {
      return;
    }
    if (state.zoomEnabled == isEnabled) {
      return;
    }
    emit(state.copyWith(zoomEnabled: isEnabled));
  }

  Future<void> _fetch({required final bool resetExistingData}) async {
    if (isClosed) {
      return;
    }
    final int requestId = ++_fetchRequestId;

    emit(
      state.copyWith(
        status: ViewStatus.loading,
        errorMessage: null,
        points: resetExistingData ? const <ChartPoint>[] : state.points,
      ),
    );

    AppError? latestError;

    await CubitExceptionHandler.executeAsync(
      operation: resetExistingData
          ? _repository.fetchTrendingCounts
          : _repository.refreshTrendingCounts,
      isAlive: () => !isClosed,
      onSuccess: (final points) {
        if (isClosed || requestId != _fetchRequestId) return;
        emit(
          state.copyWith(
            status: ViewStatus.success,
            points: points.isEmpty ? const <ChartPoint>[] : points,
            dataSource: _repository.lastSource,
          ),
        );
      },
      onAppError: (final appError) {
        if (isClosed || requestId != _fetchRequestId) return;
        latestError = appError;
      },
      onError: (final errorMessage) {
        if (isClosed || requestId != _fetchRequestId) return;
        emit(
          state.copyWith(
            status: ViewStatus.error,
            errorMessage: errorMessage,
            points: state.points,
            dataSource: ChartDataSource.unknown,
            lastError:
                latestError ?? NetworkErrorMapper.getAppError(errorMessage),
          ),
        );
      },
      logContext: 'ChartCubit._fetch',
    );
  }
}
