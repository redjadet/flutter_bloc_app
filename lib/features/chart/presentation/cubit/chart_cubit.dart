import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

part 'chart_state.dart';

class ChartCubit extends Cubit<ChartState> {
  ChartCubit({required final ChartRepository repository})
    : _repository = repository,
      super(const ChartState());

  final ChartRepository _repository;

  Future<void> load() async {
    if (state.status.isLoading) {
      return;
    }
    final List<ChartPoint>? cached = _repository.getCachedTrendingCounts();
    if (cached != null && cached.isNotEmpty && !isClosed) {
      emit(
        state.copyWith(
          status: ViewStatus.success,
          points: cached,
        ),
      );
    }
    await _fetch(resetExistingData: cached == null || cached.isEmpty);
  }

  Future<void> refresh() => _fetch(resetExistingData: false);

  void setZoomEnabled({required final bool isEnabled}) {
    if (state.zoomEnabled == isEnabled) {
      return;
    }
    emit(state.copyWith(zoomEnabled: isEnabled));
  }

  Future<void> _fetch({required final bool resetExistingData}) async {
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        clearError: true,
        points: resetExistingData ? const <ChartPoint>[] : state.points,
      ),
    );

    await CubitExceptionHandler.executeAsync(
      operation: _repository.fetchTrendingCounts,
      onSuccess: (final List<ChartPoint> points) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: ViewStatus.success,
            points: points.isEmpty ? const <ChartPoint>[] : points,
          ),
        );
      },
      onError: (final String errorMessage) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: ViewStatus.error,
            errorMessage: errorMessage,
            points: state.points,
          ),
        );
      },
      logContext: 'ChartCubit._fetch',
    );
  }
}
