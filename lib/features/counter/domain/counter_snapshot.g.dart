// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CounterSnapshotImpl _$$CounterSnapshotImplFromJson(
  Map<String, dynamic> json,
) => _$CounterSnapshotImpl(
  count: (json['count'] as num).toInt(),
  lastChanged: json['lastChanged'] == null
      ? null
      : DateTime.parse(json['lastChanged'] as String),
);

Map<String, dynamic> _$$CounterSnapshotImplToJson(
  _$CounterSnapshotImpl instance,
) => <String, dynamic>{
  'count': instance.count,
  'lastChanged': instance.lastChanged?.toIso8601String(),
};
