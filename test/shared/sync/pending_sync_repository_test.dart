import 'dart:async';

import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_test/flutter_test.dart';
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

  test('prune removes malformed stored operations', () async {
    final box = await repository.getBox();
    await box.put('bad-op', <String, dynamic>{'entityType': 'todo'});

    final int pruned = await repository.prune();

    expect(pruned, 1);
    expect(box.get('bad-op'), isNull);
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
}
