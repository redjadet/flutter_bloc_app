import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CounterSnapshot serializes to and from JSON', () {
    final CounterSnapshot snapshot = CounterSnapshot(
      userId: 'user-42',
      count: 7,
      lastChanged: DateTime.utc(2024, 1, 1, 12),
    );

    final Map<String, dynamic> json = snapshot.toJson();
    expect(json['userId'], 'user-42');
    expect(json['count'], 7);
    expect(json['lastChanged'], '2024-01-01T12:00:00.000Z');

    final CounterSnapshot roundTrip = CounterSnapshot.fromJson(json);
    expect(roundTrip, snapshot);
  });
}
