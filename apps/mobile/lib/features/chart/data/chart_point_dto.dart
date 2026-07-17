import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';

/// Wire DTO for [ChartPoint] cache and API payloads.
class ChartPointDto {
  const ChartPointDto({
    required this.date,
    required this.value,
  });

  ChartPointDto.fromDomain(final ChartPoint point) : date = point.date, value = point.value;

  factory ChartPointDto.fromJson(final Map<String, dynamic> json) => ChartPointDto(
    date: DateTime.parse(json['date'] as String),
    value: (json['value'] as num).toDouble(),
  );

  factory ChartPointDto.fromApi(final List<dynamic> entry) {
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

  final DateTime date;
  final double value;

  ChartPoint toDomain() => ChartPoint(date: date, value: value);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'date': date.toUtc().toIso8601String(),
    'value': value,
  };
}
