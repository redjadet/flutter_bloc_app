// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChartPoint _$ChartPointFromJson(Map<String, dynamic> json) => _ChartPoint(
  date: DateTime.parse(json['date'] as String),
  value: (json['value'] as num).toDouble(),
);

Map<String, dynamic> _$ChartPointToJson(_ChartPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
    };
