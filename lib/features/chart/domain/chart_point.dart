import 'package:freezed_annotation/freezed_annotation.dart';

part 'chart_point.freezed.dart';
part 'chart_point.g.dart';

@freezed
abstract class ChartPoint with _$ChartPoint {
  const factory ChartPoint({
    required final DateTime date,
    required final double value,
  }) = _ChartPoint;

  factory ChartPoint.fromJson(final Map<String, dynamic> json) =>
      _$ChartPointFromJson(json);

  factory ChartPoint.fromApi(final List<dynamic> entry) {
    if (entry.length < 2) {
      throw const FormatException('Chart entry requires timestamp and value');
    }
    final Object? timestamp = entry[0];
    final Object? rawValue = entry[1];
    if (timestamp is! num || rawValue is! num) {
      throw const FormatException('Chart entry types are invalid');
    }
    final millis = timestamp.toInt();
    final price = rawValue.toDouble();
    return ChartPoint(
      date: DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true),
      value: price,
    );
  }
}
