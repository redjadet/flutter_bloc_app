import 'package:freezed_annotation/freezed_annotation.dart';

part 'chart_point.freezed.dart';
part 'chart_point.g.dart';

@freezed
abstract class ChartPoint with _$ChartPoint {
  const factory ChartPoint({required DateTime date, required double value}) =
      _ChartPoint;

  // If you later add instance methods, also add:
  // const ChartPoint._();

  factory ChartPoint.fromJson(Map<String, dynamic> json) =>
      _$ChartPointFromJson(json);

  factory ChartPoint.fromApi(List<dynamic> entry) {
    final millis = (entry[0] as num).toInt();
    final price = (entry[1] as num).toDouble();
    return ChartPoint(
      date: DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true),
      value: price,
    );
  }
}
