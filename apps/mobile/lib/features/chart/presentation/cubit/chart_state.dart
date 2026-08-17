part of 'chart_cubit.dart';

@freezed
abstract class ChartState with _$ChartState {
  const factory ChartState({
    @Default(ViewStatus.initial) ViewStatus status,
    @Default(<ChartPoint>[]) List<ChartPoint> points,
    String? errorMessage,
    @Default(false) bool zoomEnabled,
    @Default(ChartDataSource.unknown) ChartDataSource dataSource,
    AppError? lastError,
  }) = _ChartState;

  const ChartState._();

  bool get hasPoints => points.isNotEmpty;
  bool get isEmpty => status.isSuccess && points.isEmpty;
  bool get isLoading => status.isLoading;
}
