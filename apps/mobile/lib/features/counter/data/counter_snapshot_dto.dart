import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';

/// Wire DTO for [CounterSnapshot] persistence and sync payloads.
class const CounterSnapshotDto({
  required final int count,
  final String? userId,
  final DateTime? lastChanged,
  final String? changeId,
  final DateTime? lastSyncedAt,
  final bool synchronized = false,
}) {
  CounterSnapshotDto.fromDomain(CounterSnapshot snapshot)
    : this(
        count: snapshot.count,
        userId: snapshot.userId,
        lastChanged: snapshot.lastChanged,
        changeId: snapshot.changeId,
        lastSyncedAt: snapshot.lastSyncedAt,
        synchronized: snapshot.synchronized,
      );

  factory CounterSnapshotDto.fromJson(Map<String, dynamic> json) {
    return CounterSnapshotDto(
      count: (json['count'] as num).toInt(),
      userId: json['userId'] as String?,
      lastChanged: json['lastChanged'] == null
          ? null
          : DateTime.parse(json['lastChanged'] as String),
      changeId: json['changeId'] as String?,
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      synchronized: json['synchronized'] as bool? ?? false,
    );
  }

  CounterSnapshot toDomain() => CounterSnapshot(
    count: count,
    userId: userId,
    lastChanged: lastChanged,
    changeId: changeId,
    lastSyncedAt: lastSyncedAt,
    synchronized: synchronized,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'count': count,
    'userId': userId,
    'lastChanged': lastChanged?.toIso8601String(),
    'changeId': changeId,
    'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    'synchronized': synchronized,
  };
}
