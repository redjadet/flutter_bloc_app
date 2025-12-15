import 'package:flutter_bloc_app/features/counter/data/hive_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart' as test_helpers;

void main() {
  late HiveService hiveService;
  late HiveCounterRepository repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    hiveService = await test_helpers.createHiveService();
    repository = HiveCounterRepository(hiveService: hiveService);
  });

  tearDown(() async {
    try {
      await repository.dispose();
    } catch (_) {
      // Repository might not be initialized
    }
    await test_helpers.cleanupHiveBoxes(['counter']);
  });

  test('watch emits initial snapshot derived from stored data', () async {
    final DateTime timestamp = DateTime(2024, 1, 1, 12);
    await repository.save(
      CounterSnapshot(count: 7, lastChanged: timestamp, userId: 'local'),
    );

    final CounterSnapshot snapshot = await repository.watch().first;

    expect(snapshot.count, 7);
    expect(snapshot.lastChanged, timestamp);
    expect(snapshot.userId, 'local');
  });

  test('save notifies active watchers with normalized snapshot', () async {
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
    await repository.save(const CounterSnapshot(count: 9));

    final CounterSnapshot first = await repository.watch().first;
    final CounterSnapshot second = await repository.watch().first;

    expect(first.count, 9);
    expect(first.userId, 'local');
    expect(second.count, 9);
    expect(second.userId, 'local');
  });

  test('load returns empty snapshot when no data exists', () async {
    final CounterSnapshot snapshot = await repository.load();

    expect(snapshot.count, 0);
    expect(snapshot.userId, 'local');
    expect(snapshot.lastChanged, isNull);
  });

  test('save and load work correctly', () async {
    final DateTime timestamp = DateTime(2024, 3, 1, 10);
    await repository.save(
      CounterSnapshot(count: 42, lastChanged: timestamp, userId: 'test_user'),
    );

    final CounterSnapshot loaded = await repository.load();
    expect(loaded.count, 42);
    expect(loaded.lastChanged, timestamp);
    expect(loaded.userId, 'test_user');
  });
}
