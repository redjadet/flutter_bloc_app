import 'dart:async';

import 'package:flutter_bloc_app/shared/storage/hive_schema_migration.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../test_helpers.dart' as test_helpers;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HiveService hiveService;
  late PendingSyncRepository repository;

  setUpAll(() async {
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    hiveService = await test_helpers.createHiveService();
    repository = PendingSyncRepository(hiveService: hiveService);
  });

  tearDown(() async {
    await repository.clear();
    await repository.dispose();
    await test_helpers.cleanupHiveBoxes(['pending_sync_operations']);
  });

  test('enqueue and getPendingOperations returns stored operation', () async {
    final SyncOperation operation = SyncOperation.create(
      entityType: 'counter',
      payload: <String, dynamic>{'count': 1},
      idempotencyKey: 'key-1',
    );

    await repository.enqueue(operation);

    final List<SyncOperation> pending = await repository.getPendingOperations(
      now: DateTime.now().toUtc(),
    );

    expect(pending, hasLength(1));
    expect(pending.first.id, equals(operation.id));
  });

  test(
    'enqueue dedupes by entityType + idempotencyKey (+ user scope when present)',
    () async {
      final SyncOperation op1 = SyncOperation.create(
        entityType: 'counter',
        payload: <String, dynamic>{'count': 1},
        idempotencyKey: 'same-key',
      );
      final SyncOperation op2 = SyncOperation.create(
        entityType: 'counter',
        payload: <String, dynamic>{'count': 2},
        idempotencyKey: 'same-key',
      );

      await repository.enqueue(op1);
      await repository.enqueue(op2);

      final List<SyncOperation> pending = await repository.getPendingOperations(
        now: DateTime.now().toUtc(),
      );

      expect(pending, hasLength(1));
      expect(pending.single.payload['count'], equals(2));
    },
  );

  test(
    'enqueue does not dedupe iot_demo operations across different supabase user scopes',
    () async {
      final SyncOperation userA = SyncOperation.create(
        entityType: 'iot_demo',
        payload: <String, dynamic>{
          'deviceId': 'light-1',
          'action': 'connect',
          PendingSyncRepository.payloadKeySupabaseUserId: 'user-a',
        },
        idempotencyKey: 'same-key',
      );
      final SyncOperation userB = SyncOperation.create(
        entityType: 'iot_demo',
        payload: <String, dynamic>{
          'deviceId': 'light-1',
          'action': 'connect',
          PendingSyncRepository.payloadKeySupabaseUserId: 'user-b',
        },
        idempotencyKey: 'same-key',
      );

      await repository.enqueue(userA);
      await repository.enqueue(userB);

      final List<SyncOperation> pending = await repository.getPendingOperations(
        now: DateTime.now().toUtc(),
      );

      expect(pending, hasLength(2));
      expect(
        pending
            .map(
              (final op) =>
                  op.payload[PendingSyncRepository.payloadKeySupabaseUserId],
            )
            .toSet(),
        containsAll(<String>['user-a', 'user-b']),
      );
    },
  );

  test(
    'enqueue dedupes iot_demo operations within the same supabase user scope',
    () async {
      final SyncOperation first = SyncOperation.create(
        entityType: 'iot_demo',
        payload: <String, dynamic>{
          'deviceId': 'light-1',
          'action': 'connect',
          PendingSyncRepository.payloadKeySupabaseUserId: 'user-a',
          'value': 1,
        },
        idempotencyKey: 'same-key',
      );
      final SyncOperation second = SyncOperation.create(
        entityType: 'iot_demo',
        payload: <String, dynamic>{
          'deviceId': 'light-1',
          'action': 'connect',
          PendingSyncRepository.payloadKeySupabaseUserId: 'user-a',
          'value': 2,
        },
        idempotencyKey: 'same-key',
      );

      await repository.enqueue(first);
      await repository.enqueue(second);

      final List<SyncOperation> pending = await repository.getPendingOperations(
        now: DateTime.now().toUtc(),
      );

      expect(pending, hasLength(1));
      expect(
        pending.single.payload[PendingSyncRepository.payloadKeySupabaseUserId],
        equals('user-a'),
      );
      expect(pending.single.payload['value'], equals(2));
    },
  );

  test('enqueue does not dedupe across different entityType', () async {
    final SyncOperation op1 = SyncOperation.create(
      entityType: 'counter',
      payload: <String, dynamic>{'count': 1},
      idempotencyKey: 'same-key',
    );
    final SyncOperation op2 = SyncOperation.create(
      entityType: 'chat',
      payload: <String, dynamic>{'message': 'hello'},
      idempotencyKey: 'same-key',
    );

    await repository.enqueue(op1);
    await repository.enqueue(op2);

    final List<SyncOperation> pending = await repository.getPendingOperations(
      now: DateTime.now().toUtc(),
    );

    expect(pending, hasLength(2));
    expect(pending.map((final op) => op.entityType).toSet(), {
      'counter',
      'chat',
    });
  });

  test('onOperationEnqueued emits after each successful enqueue', () async {
    final List<void> emissions = <void>[];
    final subscription = repository.onOperationEnqueued.listen(emissions.add);

    final SyncOperation op1 = SyncOperation.create(
      entityType: 'iot_demo',
      payload: <String, dynamic>{'deviceId': 'd1', 'action': 'connect'},
      idempotencyKey: 'k1',
    );
    final SyncOperation op2 = SyncOperation.create(
      entityType: 'iot_demo',
      payload: <String, dynamic>{'deviceId': 'd2', 'action': 'disconnect'},
      idempotencyKey: 'k2',
    );

    await repository.enqueue(op1);
    await Future<void>.delayed(Duration.zero);
    expect(emissions, hasLength(1));

    await repository.enqueue(op2);
    await Future<void>.delayed(Duration.zero);
    expect(emissions, hasLength(2));

    await subscription.cancel();
  });

  test('dispose closes onOperationEnqueued stream', () async {
    final Completer<void> done = Completer<void>();
    final subscription = repository.onOperationEnqueued.listen(
      (_) {},
      onDone: () => done.complete(),
    );

    await repository.dispose();

    await expectLater(done.future, completes);
    await subscription.cancel();
  });

  test('markCompleted removes operation', () async {
    final SyncOperation operation = SyncOperation.create(
      entityType: 'chat',
      payload: <String, dynamic>{'message': 'hello'},
      idempotencyKey: 'key-2',
    );
    await repository.enqueue(operation);

    await repository.markCompleted(operation.id);

    final List<SyncOperation> pending = await repository.getPendingOperations(
      now: DateTime.now().toUtc(),
    );

    expect(pending, isEmpty);
  });

  test('markFailed updates retry metadata', () async {
    final SyncOperation operation = SyncOperation.create(
      entityType: 'search',
      payload: <String, dynamic>{'query': 'bloc'},
      idempotencyKey: 'key-3',
    );
    await repository.enqueue(operation);
    final DateTime retryAt = DateTime.now().toUtc().add(
      const Duration(minutes: 5),
    );

    await repository.markFailed(
      operationId: operation.id,
      nextRetryAt: retryAt,
    );

    final List<SyncOperation> pending = await repository.getPendingOperations(
      now: DateTime.now().toUtc(),
    );

    expect(pending, isEmpty);
    final List<SyncOperation> scheduled = await repository.getPendingOperations(
      now: retryAt.add(const Duration(minutes: 1)),
    );
    expect(scheduled.first.retryCount, equals(1));
  });

  test('prune removes old or over-retried operations', () async {
    final DateTime now = DateTime.now().toUtc();
    final SyncOperation stale = SyncOperation.create(
      entityType: 'chat',
      payload: <String, dynamic>{},
      idempotencyKey: 'stale',
    ).copyWith(nextRetryAt: now.subtract(const Duration(days: 40)));
    final SyncOperation retries = SyncOperation.create(
      entityType: 'counter',
      payload: <String, dynamic>{},
      idempotencyKey: 'retry',
    ).copyWith(retryCount: 12);
    await repository.enqueue(stale);
    await repository.enqueue(retries);

    final int pruned = await repository.prune(
      maxRetryCount: 10,
      maxAge: const Duration(days: 30),
    );

    expect(pruned, 2);
    final List<SyncOperation> remaining = await repository.getPendingOperations(
      now: now,
    );
    expect(remaining, isEmpty);
  });

  test('getPendingOperations removes malformed stored operations', () async {
    final SyncOperation valid = SyncOperation.create(
      entityType: 'todo',
      payload: <String, dynamic>{'title': 'valid'},
      idempotencyKey: 'valid-key',
    );
    await repository.enqueue(valid);

    final box = await repository.getBox();
    await box.put('bad-op', <String, dynamic>{'entityType': 'todo'});

    final List<SyncOperation> pending = await repository.getPendingOperations(
      now: DateTime.now().toUtc(),
    );

    expect(pending, hasLength(1));
    expect(pending.first.id, valid.id);
    expect(box.get('bad-op'), isNull);
  });

  test(
    'getPendingOperations ignores schema meta and dead-letter keys',
    () async {
      final SyncOperation valid = SyncOperation.create(
        entityType: 'todo',
        payload: <String, dynamic>{'title': 'valid'},
        idempotencyKey: 'valid-key',
      );
      await repository.enqueue(valid);

      final box = await repository.getBox();
      await box.put(
        HiveSchemaMigratorService.metaKeyFingerprints,
        <String, String>{'pending_sync_operations:v1': 'fingerprint'},
      );
      await box.put('dead_letter:bad-op', <String, dynamic>{'error': 'bad'});

      final List<SyncOperation> pending = await repository.getPendingOperations(
        now: DateTime.now().toUtc(),
      );

      expect(pending, hasLength(1));
      expect(pending.single.id, valid.id);
      expect(box.get(HiveSchemaMigratorService.metaKeyFingerprints), isNotNull);
      expect(box.get('dead_letter:bad-op'), isNotNull);
    },
  );

  test('prune removes malformed stored operations', () async {
    final box = await repository.getBox();
    await box.put('bad-op', <String, dynamic>{'entityType': 'todo'});

    final int pruned = await repository.prune();

    expect(pruned, 1);
    expect(box.get('bad-op'), isNull);
  });

  test('prune deletes over-retried entries by stored key', () async {
    final SyncOperation operation = SyncOperation.create(
      entityType: 'counter',
      payload: <String, dynamic>{'count': 9},
      idempotencyKey: 'mismatch-key',
    ).copyWith(retryCount: 12);

    final box = await repository.getBox();
    await box.put('custom-storage-key', operation.toJson());

    final int pruned = await repository.prune(
      maxRetryCount: 10,
      maxAge: const Duration(days: 30),
    );

    expect(pruned, 1);
    expect(box.get('custom-storage-key'), isNull);
  });

  group('schema migrate: pending_sync_operations:v1', () {
    test(
      'quarantines malformed legacy ops to dead_letter:<originalKey> then deletes originals',
      () async {
        await hiveService.openBoxAndRun<void>(
          'pending_sync_operations',
          action: (final box) async {
            await box.put('not-a-map', 123);
            await box.put('missing-fields', <String, dynamic>{
              'entityType': 'x',
            });
            final SyncOperation legacyIot = SyncOperation.create(
              entityType: 'iot_demo',
              payload: <String, dynamic>{'deviceId': 'd1', 'action': 'connect'},
              idempotencyKey: 'k1',
            );
            await box.put('legacy-iot', legacyIot.toJson());
          },
        );

        // Triggers ensureSchema + migration.
        final List<SyncOperation> pending = await repository
            .getPendingOperations(now: DateTime.now().toUtc());
        expect(pending, isEmpty);

        final box = await repository.getBox();
        expect(box.get('not-a-map'), isNull);
        expect(box.get('missing-fields'), isNull);
        expect(box.get('legacy-iot'), isNull);

        final dynamic dl1 = box.get('dead_letter:not-a-map');
        expect(dl1, isA<Map>());
        expect((dl1 as Map)['schema'], equals('dead_letter:v1'));
        expect(dl1['originalKey'], equals('not-a-map'));
        expect(dl1['error'], equals('value_not_map'));
        expect(dl1['originalValue'], equals(123));
        expect(dl1['quarantinedAt'], isA<String>());

        final dynamic dl2 = box.get('dead_letter:missing-fields');
        expect(dl2, isA<Map>());
        expect((dl2 as Map)['schema'], equals('dead_letter:v1'));
        expect(dl2['originalKey'], equals('missing-fields'));
        expect(dl2['error'], equals('sync_operation_parse_failed'));

        final dynamic dl3 = box.get('dead_letter:legacy-iot');
        expect(dl3, isA<Map>());
        expect((dl3 as Map)['schema'], equals('dead_letter:v1'));
        expect(dl3['originalKey'], equals('legacy-iot'));
        expect(dl3['error'], equals('iot_demo_missing_user_id'));
        expect(dl3['originalValue'], isA<Map>());

        final Map<dynamic, dynamic>? meta =
            box.get(HiveSchemaMigratorService.metaKeyFingerprints)
                as Map<dynamic, dynamic>?;
        expect(meta?['pending_sync_operations:v1'], isNotNull);
      },
    );

    test(
      'migration rerun is idempotent and does not overwrite dead-letter',
      () async {
        await hiveService.openBoxAndRun<void>(
          'pending_sync_operations',
          action: (final box) async {
            await box.put('not-a-map', 123);
          },
        );

        await repository.getPendingOperations(now: DateTime.now().toUtc());
        final box = await repository.getBox();
        final Map<dynamic, dynamic> first =
            box.get('dead_letter:not-a-map') as Map<dynamic, dynamic>;
        final String quarantinedAt1 = first['quarantinedAt'] as String;

        // Re-run ensureSchema. Dead-letter should be preserved.
        await repository.getPendingOperations(now: DateTime.now().toUtc());
        final Map<dynamic, dynamic> second =
            box.get('dead_letter:not-a-map') as Map<dynamic, dynamic>;
        expect(second['quarantinedAt'], equals(quarantinedAt1));
      },
    );

    test('migration does not emit onOperationEnqueued', () async {
      await hiveService.openBoxAndRun<void>(
        'pending_sync_operations',
        action: (final box) async {
          await box.put('not-a-map', 123);
        },
      );

      final List<void> emissions = <void>[];
      final subscription = repository.onOperationEnqueued.listen(emissions.add);

      await repository.getPendingOperations(now: DateTime.now().toUtc());
      await Future<void>.delayed(Duration.zero);
      expect(emissions, isEmpty);

      await subscription.cancel();
    });

    test(
      'migration does not create read noise for box.watch consumers',
      () async {
        await hiveService.openBoxAndRun<void>(
          'pending_sync_operations',
          action: (final box) async {
            await box.put('not-a-map', 123);
          },
        );

        final Box<dynamic> box = await repository.getBox();
        final List<BoxEvent> events = <BoxEvent>[];
        final StreamSubscription<BoxEvent> sub = box.watch().listen(events.add);

        // Trigger a second open (ensureSchema rerun) and a read.
        await repository.getPendingOperations(now: DateTime.now().toUtc());
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // We expect at most dead-letter + meta writes; no original key remains.
        expect(box.get('not-a-map'), isNull);
        expect(box.get('dead_letter:not-a-map'), isNotNull);
        expect(
          box.get(HiveSchemaMigratorService.metaKeyFingerprints),
          isNotNull,
        );

        // Assert no event for the original key (it should be deleted, not updated).
        expect(events.any((final e) => e.key == 'not-a-map'), isFalse);

        // Assert any watch events are only for meta/dead-letter.
        expect(
          events.every(
            (final e) =>
                e.key == HiveSchemaMigratorService.metaKeyFingerprints ||
                (e.key is String &&
                    (e.key as String).startsWith('dead_letter:')),
          ),
          isTrue,
        );

        await sub.cancel();
      },
    );
  });

  test(
    'getPendingOperations with supabaseUserIdFilter returns only iot_demo ops for that user',
    () async {
      final SyncOperation counterOp = SyncOperation.create(
        entityType: 'counter',
        payload: <String, dynamic>{'count': 1},
        idempotencyKey: 'counter-1',
      );
      final SyncOperation iotUserA = SyncOperation.create(
        entityType: 'iot_demo',
        payload: <String, dynamic>{
          'deviceId': 'light-1',
          'action': 'connect',
          PendingSyncRepository.payloadKeySupabaseUserId: 'user-a',
        },
        idempotencyKey: 'iot-a-1',
      );
      final SyncOperation iotUserB = SyncOperation.create(
        entityType: 'iot_demo',
        payload: <String, dynamic>{
          'deviceId': 'light-1',
          'action': 'connect',
          PendingSyncRepository.payloadKeySupabaseUserId: 'user-b',
        },
        idempotencyKey: 'iot-b-1',
      );
      await repository.enqueue(counterOp);
      await repository.enqueue(iotUserA);
      await repository.enqueue(iotUserB);

      final List<SyncOperation> forUserA = await repository
          .getPendingOperations(
            now: DateTime.now().toUtc(),
            supabaseUserIdFilter: 'user-a',
          );
      expect(forUserA, hasLength(2));
      expect(
        forUserA.map((final o) => o.entityType).toSet(),
        containsAll(<String>['counter', 'iot_demo']),
      );
      expect(
        forUserA
            .where((final o) => o.entityType == 'iot_demo')
            .every(
              (final o) =>
                  o.payload[PendingSyncRepository.payloadKeySupabaseUserId] ==
                  'user-a',
            ),
        isTrue,
      );

      final List<SyncOperation> forUserB = await repository
          .getPendingOperations(
            now: DateTime.now().toUtc(),
            supabaseUserIdFilter: 'user-b',
          );
      expect(
        forUserB
            .where((final o) => o.entityType == 'iot_demo')
            .single
            .payload[PendingSyncRepository.payloadKeySupabaseUserId],
        equals('user-b'),
      );
    },
  );

  test(
    'getPendingOperations with supabaseUserIdFilter excludes legacy iot_demo ops without user id',
    () async {
      final SyncOperation legacyIotOp = SyncOperation.create(
        entityType: 'iot_demo',
        payload: <String, dynamic>{
          'deviceId': 'legacy-device',
          'action': 'connect',
        },
        idempotencyKey: 'legacy-iot',
      );
      final SyncOperation scopedIotOp = SyncOperation.create(
        entityType: 'iot_demo',
        payload: <String, dynamic>{
          'deviceId': 'scoped-device',
          'action': 'connect',
          PendingSyncRepository.payloadKeySupabaseUserId: 'user-a',
        },
        idempotencyKey: 'scoped-iot',
      );
      await repository.enqueue(legacyIotOp);
      await repository.enqueue(scopedIotOp);

      final List<SyncOperation> filtered = await repository
          .getPendingOperations(
            now: DateTime.now().toUtc(),
            supabaseUserIdFilter: 'user-a',
          );

      expect(filtered, hasLength(1));
      expect(filtered.single.id, scopedIotOp.id);
    },
  );
}
