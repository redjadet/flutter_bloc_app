import 'package:flutter_bloc_app/features/counter/data/hive_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/storage/hive_schema_migration.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

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
    // Watch helper starts async box watch on listen. Give it a moment to settle
    // before deleting the underlying box files, otherwise Hive can throw
    // PathNotFoundException after the test already completed.
    await Future<void>.delayed(const Duration(milliseconds: 50));
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

  test('schema migrate coerces legacy stored primitives', () async {
    await hiveService.openBoxAndRun<void>(
      'counter',
      action: (final box) async {
        await box.put('count', '7');
        await box.put('last_changed', '2024-01-01T00:00:00Z');
        await box.put('last_synced_at', '123');
        await box.put('synchronized', 'true');
        await box.put('user_id', '');
        await box.put('change_id', 9);
      },
    );

    final CounterSnapshot snapshot = await repository.load();
    expect(snapshot.count, 7);
    expect(snapshot.lastChanged?.toUtc(), DateTime.utc(2024, 1, 1));
    expect(snapshot.lastSyncedAt?.millisecondsSinceEpoch, 123);
    expect(snapshot.synchronized, isTrue);
    expect(snapshot.userId, 'local'); // invalid user_id deleted -> default

    final box = await repository.getBox();
    expect(box.get('count'), isA<int>());
    expect(box.get('last_changed'), isA<int>());
    expect(box.get('last_synced_at'), isA<int>());
    expect(box.get('synchronized'), isA<bool>());
    expect(box.get('user_id'), isNull);
    expect(box.get('change_id'), isNull);

    final Map<dynamic, dynamic>? meta =
        box.get(HiveSchemaMigratorService.metaKeyFingerprints)
            as Map<dynamic, dynamic>?;
    expect(meta?['counter:v1'], isNotNull);
  });

  test(
    'schema migrate deletes invalid timestamps and trims legacy strings',
    () async {
      await hiveService.openBoxAndRun<void>(
        'counter',
        action: (final box) async {
          await box.put('count', ' 8 ');
          await box.put('last_changed', -1);
          await box.put('last_synced_at', double.nan);
          await box.put('synchronized', ' TRUE ');
          await box.put('user_id', ' local-user ');
          await box.put('change_id', ' change-1 ');
        },
      );

      final CounterSnapshot snapshot = await repository.load();

      expect(snapshot.count, 8);
      expect(snapshot.lastChanged, isNull);
      expect(snapshot.lastSyncedAt, isNull);
      expect(snapshot.synchronized, isTrue);
      expect(snapshot.userId, 'local-user');
      expect(snapshot.changeId, 'change-1');

      final box = await repository.getBox();
      expect(box.get('last_changed'), isNull);
      expect(box.get('last_synced_at'), isNull);
    },
  );

  test('schema fingerprint not written when migrator throws', () async {
    final HiveCounterRepository throwing = _ThrowingCounterRepository(
      hiveService: hiveService,
    );

    await throwing.load();

    final box = await throwing.getBox();
    final Map<dynamic, dynamic>? meta =
        box.get(HiveSchemaMigratorService.metaKeyFingerprints)
            as Map<dynamic, dynamic>?;
    expect(meta?['counter:v1'], isNull);
  });
}

class _ThrowingCounterRepository extends HiveCounterRepository {
  _ThrowingCounterRepository({required super.hiveService});

  @override
  HiveBoxSchema get schema => const HiveBoxSchema(
    boxName: 'counter',
    namespace: 'counter:v1',
    fingerprint: 'throwing',
    migrate: _throwingMigrator,
  );

  static Future<void> _throwingMigrator(
    final Box<dynamic> box, {
    required final String? fromFingerprint,
  }) async {
    throw Exception('boom');
  }
}
