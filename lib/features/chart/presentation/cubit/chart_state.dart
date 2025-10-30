part of 'chart_cubit.dart';

class ChartState extends Equatable {
  const ChartState({
    this.status = ViewStatus.initial,
    this.points = const <ChartPoint>[],
    this.errorMessage,
    this.zoomEnabled = false,
  });

  final ViewStatus status;
  final List<ChartPoint> points;
  final String? errorMessage;
  final bool zoomEnabled;

  bool get hasPoints => points.isNotEmpty;
  bool get isEmpty => status.isSuccess && points.isEmpty;
  bool get isLoading => status.isLoading;

  ChartState copyWith({
    final ViewStatus? status,
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
