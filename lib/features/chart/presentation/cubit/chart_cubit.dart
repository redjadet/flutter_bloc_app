import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';

part 'chart_state.dart';

class ChartCubit extends Cubit<ChartState> {
  ChartCubit({required final ChartRepository repository})
    : _repository = repository,
      super(const ChartState());

  final ChartRepository _repository;

  Future<void> load() async {
    if (state.status == ChartStatus.loading) {
      return;
    }
    await _fetch(resetExistingData: true);
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
        status: ChartStatus.loading,
        clearError: true,
        points: resetExistingData ? const <ChartPoint>[] : state.points,
      ),
    );

    try {
      final List<ChartPoint> points = await _repository.fetchTrendingCounts();

      if (points.isEmpty) {
        emit(
          state.copyWith(
            status: ChartStatus.empty,
            points: const <ChartPoint>[],
          ),
        );
        return;
      }

      emit(state.copyWith(status: ChartStatus.success, points: points));
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: ChartStatus.failure,
          errorMessage: error.toString(),
          points: state.points,
        ),
      );
    }
  }
}
