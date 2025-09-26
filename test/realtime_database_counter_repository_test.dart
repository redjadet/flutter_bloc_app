import 'package:flutter_bloc_app/features/counter/data/realtime_database_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RealtimeDatabaseCounterRepository.snapshotFromValue', () {
    test('returns empty snapshot when value is null', () {
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(null);

      expect(result.count, 0);
      expect(result.lastChanged, isNull);
    });

    test('parses map payload with count and timestamp', () {
      final DateTime expected = DateTime.fromMillisecondsSinceEpoch(42);
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(<String, Object?>{
            'count': 5,
            'last_changed': expected.millisecondsSinceEpoch,
          });

      expect(result.count, 5);
      expect(result.lastChanged, expected);
    });

    test('defaults missing fields to safe values', () {
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(<String, Object?>{
            'count': null,
            'last_changed': null,
          });

      expect(result.count, 0);
      expect(result.lastChanged, isNull);
    });

    test('parses numeric payload into snapshot', () {
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(7);

      expect(result.count, 7);
      expect(result.lastChanged, isNull);
    });

    test('returns empty snapshot for unsupported payload', () {
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue('unexpected');

      expect(result.count, 0);
      expect(result.lastChanged, isNull);
    });
  });
}
