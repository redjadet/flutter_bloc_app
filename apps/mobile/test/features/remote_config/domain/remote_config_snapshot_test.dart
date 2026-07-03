import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoteConfigSnapshot', () {
    test('creates snapshot with values', () {
      final snapshot = RemoteConfigSnapshot(
        values: {'key1': 'value1', 'key2': 42},
      );

      expect(snapshot.values, {'key1': 'value1', 'key2': 42});
      expect(snapshot.hasValues, isTrue);
    });

    test('empty snapshot has no values', () {
      expect(RemoteConfigSnapshot.empty.values, isEmpty);
      expect(RemoteConfigSnapshot.empty.hasValues, isFalse);
    });

    test('getValue returns correct type', () {
      final snapshot = RemoteConfigSnapshot(
        values: {'stringKey': 'value', 'intKey': 42, 'boolKey': true},
      );

      expect(snapshot.getValue<String>('stringKey'), 'value');
      expect(snapshot.getValue<int>('intKey'), 42);
      expect(snapshot.getValue<bool>('boolKey'), isTrue);
    });

    test('getValue returns null for wrong type', () {
      final snapshot = RemoteConfigSnapshot(values: {'key': 'value'});

      expect(snapshot.getValue<int>('key'), isNull);
    });

    test('getValue returns null for missing key', () {
      final snapshot = RemoteConfigSnapshot(values: {'key': 'value'});

      expect(snapshot.getValue<String>('missing'), isNull);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = RemoteConfigSnapshot(
        values: {'key1': 'value1'},
        lastFetchedAt: DateTime.utc(2024, 1, 1),
      );

      final updated = original.copyWith(
        values: {'key2': 'value2'},
        lastFetchedAt: DateTime.utc(2024, 1, 2),
      );

      expect(updated.values, {'key2': 'value2'});
      expect(updated.lastFetchedAt, DateTime.utc(2024, 1, 2));
      expect(updated, isNot(same(original)));
    });

    test('copyWith preserves all fields when no changes', () {
      final original = RemoteConfigSnapshot(
        values: {'key1': 'value1'},
        lastFetchedAt: DateTime.utc(2024, 1, 1),
        templateVersion: 'v1',
        dataSource: 'remote',
        lastSyncedAt: DateTime.utc(2024, 1, 1),
      );

      final copied = original.copyWith();

      expect(copied.values, original.values);
      expect(copied.lastFetchedAt, original.lastFetchedAt);
      expect(copied.templateVersion, original.templateVersion);
      expect(copied.dataSource, original.dataSource);
      expect(copied.lastSyncedAt, original.lastSyncedAt);
    });

    test('equality works correctly', () {
      final snapshot1 = RemoteConfigSnapshot(
        values: {'key': 'value'},
        lastFetchedAt: DateTime.utc(2024, 1, 1),
      );

      final snapshot2 = RemoteConfigSnapshot(
        values: {'key': 'value'},
        lastFetchedAt: DateTime.utc(2024, 1, 1),
      );

      expect(snapshot1, equals(snapshot2));
      expect(snapshot1.hashCode, equals(snapshot2.hashCode));
    });

    test('values are unmodifiable', () {
      final snapshot = RemoteConfigSnapshot(values: {'key': 'value'});

      expect(
        () => snapshot.values['newKey'] = 'newValue',
        throwsA(isA<Error>()),
      );
    });
  });
}
