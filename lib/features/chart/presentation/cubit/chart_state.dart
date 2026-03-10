part of 'chart_cubit.dart';

@freezed
abstract class ChartState with _$ChartState {
  const factory ChartState({
    @Default(ViewStatus.initial) final ViewStatus status,
    @Default(<ChartPoint>[]) final List<ChartPoint> points,
    final String? errorMessage,
    @Default(false) final bool zoomEnabled,
    @Default(ChartDataSource.unknown) final ChartDataSource dataSource,
  }) = _ChartState;

  const ChartState._();

  bool get hasPoints => points.isNotEmpty;
  bool get isEmpty => status.isSuccess && points.isEmpty;
  bool get isLoading => status.isLoading;
}
