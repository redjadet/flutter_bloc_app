import 'package:flutter_bloc_app/features/counter/data/realtime_database_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RealtimeDatabaseCounterRepository.snapshotFromValue', () {
    test('returns empty snapshot when value is null', () {
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(
        null,
        userId: 'user-1',
      );

      expect(result.count, 0);
      expect(result.lastChanged, isNull);
      expect(result.userId, 'user-1');
    });

    test('parses map payload with count and timestamp', () {
      final DateTime expected = DateTime.fromMillisecondsSinceEpoch(42);
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(<String, Object?>{
            'userId': 'user-2',
            'count': 5,
            'last_changed': expected.millisecondsSinceEpoch,
          }, userId: 'ignored');

      expect(result.count, 5);
      expect(result.lastChanged, expected);
      expect(result.userId, 'user-2');
    });

    test('defaults missing fields to safe values', () {
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(<String, Object?>{
            'count': null,
            'last_changed': null,
          }, userId: 'user-3');

      expect(result.count, 0);
      expect(result.lastChanged, isNull);
      expect(result.userId, 'user-3');
    });

    test('parses numeric payload into snapshot', () {
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(7, userId: 'user-4');

      expect(result.count, 7);
      expect(result.lastChanged, isNull);
      expect(result.userId, 'user-4');
    });

    test('returns empty snapshot for unsupported payload', () {
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(
        'unexpected',
        userId: 'test-user',
        logUnexpected: false,
      );

      expect(result.count, 0);
      expect(result.lastChanged, isNull);
      expect(result.userId, 'test-user');
    });
  });
}
