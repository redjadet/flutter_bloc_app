import 'package:freezed_annotation/freezed_annotation.dart';

part 'chart_point.freezed.dart';

@freezed
abstract class ChartPoint with _$ChartPoint {
  const factory ChartPoint({
    required DateTime date,
    required double value,
  }) = _ChartPoint;
}
