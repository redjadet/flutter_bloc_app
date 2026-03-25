import 'dart:async';

import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:flutter_bloc_app/shared/utils/stream_controller_lifecycle.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'pending_sync_repository_codec.dart';

/// A repository for managing a queue of [SyncOperation]s that need to be
/// processed and synchronized with a remote backend.
///
/// It uses Hive for persistent, encrypted storage.
class PendingSyncRepository extends HiveRepositoryBase {
  PendingSyncRepository({required super.hiveService});

  static const String _boxName = 'pending_sync_operations';

  final StreamController<void> _enqueuedController =
      StreamController<void>.broadcast();

  @override
  String get boxName => _boxName;

  /// Fires once after each successful [enqueue]. Used to trigger immediate
  /// sync so IoT demo (and other) changes reach Supabase as soon as possible.
  Stream<void> get onOperationEnqueued => _enqueuedController.stream;

  Future<void> dispose() async {
    if (_enqueuedController.isClosed) {
      return;
    }
    await _enqueuedController.close();
  }

  /// Adds a [SyncOperation] to the pending queue.
  Future<SyncOperation> enqueue(final SyncOperation operation) async {
    await StorageGuard.run<void>(
      logContext: 'PendingSyncRepository.enqueue',
      action: () async {
        final Box<dynamic> box = await getBox();
        final _PendingOperationsReadResult readResult = _readOperations(
          box.toMap(),
        );
        await _deleteKeys(box, readResult.malformedKeys);

        final String? userScope = _userScopeForDedupe(operation);
        final List<dynamic> duplicateKeys = readResult.operations
            .where(
              (final entry) =>
                  entry.operation.entityType == operation.entityType &&
                  entry.operation.idempotencyKey == operation.idempotencyKey &&
                  _userScopeForDedupe(entry.operation) == userScope,
            )
            .map((final entry) => entry.key)
            .toList(growable: false);
        final int duplicateCount = duplicateKeys.length;
        if (duplicateCount > 0) {
          AppLogger.debug(
            'PendingSyncRepository.enqueue deduped $duplicateCount operation(s): '
            'entityType=${operation.entityType} '
            'idempotencyKey=${operation.idempotencyKey} '
            'userScope=${userScope ?? 'none'}',
          );
        }
        await _deleteKeys(box, duplicateKeys);
        await box.put(operation.id, operation.toJson());
        StreamControllerSafeEmit.safeAdd(_enqueuedController, null);
      },
    );
    return operation;
  }

  /// Key in payload for user-scoped sync (e.g. IoT demo); ops without this
  /// for the iot_demo entity type are legacy and are excluded when filter is set.
  static const String payloadKeySupabaseUserId = 'supabaseUserId';

  // Best-effort user scope for dedupe. Not all operations are user-scoped yet;
  // return null when the payload doesn't have a stable user identifier.
  String? _userScopeForDedupe(final SyncOperation operation) {
    final dynamic uid = operation.payload[payloadKeySupabaseUserId];
    return uid is String && uid.isNotEmpty ? uid : null;
  }

  /// Retrieves a list of pending [SyncOperation]s that are ready to be retried.
  ///
  /// Operations are sorted by their creation time.
  /// The [now] parameter can be used to deterministically filter operations
  /// based on their `nextRetryAt` timestamp, which is useful for testing.
  /// The [limit] parameter can be used to control the batch size.
  /// When [supabaseUserIdFilter] is set, only iot_demo ops whose
  /// payload supabaseUserId equals this value are included.
  Future<List<SyncOperation>> getPendingOperations({
    final DateTime? now,
    final int? limit,
    final String? supabaseUserIdFilter,
  }) async => StorageGuard.run<List<SyncOperation>>(
    logContext: 'PendingSyncRepository.getPendingOperations',
    action: () async {
      final Box<dynamic> box = await getBox();
      final _PendingOperationsReadResult readResult = _readOperations(
        box.toMap(),
      );
      final List<SyncOperation> operations =
          readResult.operations.map((final entry) => entry.operation).toList()
            ..sort((final a, final b) => a.createdAt.compareTo(b.createdAt));
      await _deleteKeys(box, readResult.malformedKeys);

      final DateTime threshold = (now ?? DateTime.now()).toUtc();
      Iterable<SyncOperation> ready = operations.where(
        (final op) => _isReadyForRetry(op, threshold),
      );
      if (supabaseUserIdFilter != null) {
        ready = ready.where(
          (final op) => _matchesSupabaseUserIdFilter(op, supabaseUserIdFilter),
        );
      }

      final List<SyncOperation> pending = limit != null
          ? ready.take(limit).toList(growable: false)
          : ready.toList(growable: false);
      return pending;
    },
    fallback: () => const <SyncOperation>[],
  );

  /// Removes a successfully synchronized operation from the queue.
  Future<void> markCompleted(final String operationId) async {
    await StorageGuard.run<void>(
      logContext: 'PendingSyncRepository.markCompleted',
      action: () async {
        final Box<dynamic> box = await getBox();
        await box.delete(operationId);
      },
    );
  }

  /// Updates an operation that failed to sync with a new retry timestamp.
  Future<void> markFailed({
    required final String operationId,
    required final DateTime nextRetryAt,
    final int? retryCount,
  }) async {
    await StorageGuard.run<void>(
      logContext: 'PendingSyncRepository.markFailed',
      action: () async {
        final Box<dynamic> box = await getBox();
        final dynamic stored = box.get(operationId);
        if (stored is! Map<dynamic, dynamic>) {
          await box.delete(operationId);
          return;
        }

        final SyncOperation? existing = _operationFromJsonOrNull(stored);
        if (existing == null) {
          await box.delete(operationId);
          return;
        }
        final SyncOperation updated = existing.copyWith(
          nextRetryAt: nextRetryAt,
          retryCount: retryCount ?? (existing.retryCount + 1),
        );
        await box.put(operationId, updated.toJson());
      },
    );
  }

  /// Clears all pending operations from the queue.
  Future<void> clear() async {
    await StorageGuard.run<void>(
      logContext: 'PendingSyncRepository.clear',
      action: () async {
        final Box<dynamic> box = await getBox();
        await box.clear();
      },
    );
  }

  /// Prunes operations that have exceeded retry limits or are too old to retry.
  ///
  /// Returns the number of pruned operations.
  Future<int> prune({
    final int maxRetryCount = 10,
    final Duration maxAge = const Duration(days: 30),
  }) async => StorageGuard.run<int>(
    logContext: 'PendingSyncRepository.prune',
    action: () async {
      final Box<dynamic> box = await getBox();
      final DateTime cutoff = DateTime.now().toUtc().subtract(maxAge);
      final _PendingOperationsReadResult readResult = _readOperations(
        box.toMap(),
      );
      final List<dynamic> keysToDelete = <dynamic>[
        ...readResult.malformedKeys,
        ...readResult.operations
            .where(
              (final entry) =>
                  entry.operation.retryCount >= maxRetryCount ||
                  _isOlderThanCutoff(entry.operation, cutoff),
            )
            .map((final entry) => entry.key),
      ];
      await _deleteKeys(box, keysToDelete);
      return keysToDelete.length;
    },
    fallback: () => 0,
  );
}
