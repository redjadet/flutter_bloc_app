import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';

/// Wire DTO for [ChartPoint] cache and API payloads.
class const ChartPointDto({
  required final DateTime date,
  required final double value,
}) {
  ChartPointDto.fromDomain(ChartPoint point)
    : this(
        date: point.date,
        value: point.value,
      );

  factory ChartPointDto.fromJson(Map<String, dynamic> json) => ChartPointDto(
    date: DateTime.parse(json['date'] as String),
    value: (json['value'] as num).toDouble(),
  );

  factory ChartPointDto.fromApi(List<dynamic> entry) {
    if (entry.length < 2) {
      throw const FormatException('Chart entry requires timestamp and value');
    }
    final Object? timestamp = entry[0];
    final Object? rawValue = entry[1];
    if (timestamp is! num || rawValue is! num) {
      throw const FormatException('Chart entry types are invalid');
    }
    return ChartPointDto(
      date: DateTime.fromMillisecondsSinceEpoch(
        timestamp.toInt(),
        isUtc: true,
      ),
      value: rawValue.toDouble(),
    );
  }

  ChartPoint toDomain() => ChartPoint(date: date, value: value);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'date': date.toUtc().toIso8601String(),
    'value': value,
  };
}
