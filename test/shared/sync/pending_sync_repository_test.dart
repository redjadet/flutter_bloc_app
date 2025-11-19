import 'dart:io';

import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late HiveService hiveService;
  late PendingSyncRepository repository;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    final HiveKeyManager keyManager = HiveKeyManager(
      storage: InMemorySecretStorage(),
    );
    hiveService = HiveService(keyManager: keyManager);
    await hiveService.initialize();
    repository = PendingSyncRepository(hiveService: hiveService);
  });

  tearDown(() async {
    await repository.clear();
    try {
      await Hive.deleteBoxFromDisk('pending_sync_operations');
    } catch (_) {}
    tempDir.deleteSync(recursive: true);
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
}
