import 'package:flutter_bloc_app/features/counter/data/counter_snapshot_dto.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CounterSnapshotDto serializes to and from JSON', () {
    final CounterSnapshot snapshot = CounterSnapshot(
      userId: 'user-42',
      count: 7,
      lastChanged: DateTime.utc(2024, 1, 1, 12),
    );

    final Map<String, dynamic> json = CounterSnapshotDto.fromDomain(
      snapshot,
    ).toJson();
    expect(json['userId'], 'user-42');
    expect(json['count'], 7);
    expect(json['lastChanged'], '2024-01-01T12:00:00.000Z');

    final CounterSnapshot roundTrip = CounterSnapshotDto.fromJson(
      json,
    ).toDomain();
    expect(roundTrip, snapshot);
  });
}
