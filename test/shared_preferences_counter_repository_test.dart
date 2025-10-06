import 'package:flutter_bloc_app/features/counter/data/shared_preferences_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'watch emits initial snapshot derived from stored preferences',
    () async {
      final DateTime timestamp = DateTime(2024, 1, 1, 12);
      SharedPreferences.setMockInitialValues(<String, Object>{
        'last_count': 7,
        'last_changed': timestamp.millisecondsSinceEpoch,
      });

      final SharedPreferencesCounterRepository repository =
          SharedPreferencesCounterRepository();
      addTearDown(repository.dispose);

      final CounterSnapshot snapshot = await repository.watch().first;

      expect(snapshot.count, 7);
      expect(snapshot.lastChanged, timestamp);
      expect(snapshot.userId, 'local');
    },
  );

  test('save notifies active watchers with normalized snapshot', () async {
    final SharedPreferencesCounterRepository repository =
        SharedPreferencesCounterRepository();
    addTearDown(repository.dispose);
    final DateTime timestamp = DateTime(2024, 2, 1, 9, 30);

    final Future expectation = expectLater(
      repository.watch(),
      emitsThrough(
        isA<CounterSnapshot>()
            .having((s) => s.count, 'count', 5)
            .having((s) => s.userId, 'userId', 'local')
            .having((s) => s.lastChanged, 'lastChanged', timestamp),
      ),
    );

    await repository.save(CounterSnapshot(count: 5, lastChanged: timestamp));

    await expectation;
  });

  test('watch replays cached snapshot for later listeners', () async {
    final SharedPreferencesCounterRepository repository =
        SharedPreferencesCounterRepository();
    addTearDown(repository.dispose);

    await repository.save(const CounterSnapshot(count: 9));

    final CounterSnapshot first = await repository.watch().first;
    final CounterSnapshot second = await repository.watch().first;

    expect(first.count, 9);
    expect(first.userId, 'local');
    expect(second.count, 9);
    expect(second.userId, 'local');
  });
}
