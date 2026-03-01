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
}
