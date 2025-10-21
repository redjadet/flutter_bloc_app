part of 'chart_cubit.dart';

enum ChartStatus { initial, loading, success, empty, failure }

class ChartState extends Equatable {
  const ChartState({
    this.status = ChartStatus.initial,
    this.points = const <ChartPoint>[],
    this.errorMessage,
    this.zoomEnabled = false,
  });

  final ChartStatus status;
  final List<ChartPoint> points;
  final String? errorMessage;
  final bool zoomEnabled;

  ChartState copyWith({
    final ChartStatus? status,
    final List<ChartPoint>? points,
    final bool? zoomEnabled,
    final String? errorMessage,
    final bool clearError = false,
  }) => ChartState(
    status: status ?? this.status,
    points: points ?? this.points,
    zoomEnabled: zoomEnabled ?? this.zoomEnabled,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    points,
    errorMessage,
    zoomEnabled,
  ];
}
