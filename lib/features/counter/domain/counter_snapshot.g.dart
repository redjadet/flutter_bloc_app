// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CounterSnapshot _$CounterSnapshotFromJson(Map<String, dynamic> json) =>
    _CounterSnapshot(
      count: (json['count'] as num).toInt(),
      lastChanged: json['lastChanged'] == null
          ? null
          : DateTime.parse(json['lastChanged'] as String),
    );

Map<String, dynamic> _$CounterSnapshotToJson(_CounterSnapshot instance) =>
    <String, dynamic>{
      'count': instance.count,
      'lastChanged': instance.lastChanged?.toIso8601String(),
    };
