import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:utilities/utilities.dart';

import '../hive/hive_repository_base.dart';
import '../hive/hive_schema_fingerprints.g.dart';
import '../hive/hive_schema_migration.dart';
import '../utils/storage_guard.dart';
import 'sync_operation.dart';

part 'pending_sync_repository_codec.dart';
part 'pending_sync_repository_migration.dart';
part 'pending_sync_repository_mutations.part.dart';

/// A repository for managing a queue of [SyncOperation]s that need to be
/// processed and synchronized with a remote backend.
///
/// It uses Hive for persistent, encrypted storage.
class PendingSyncRepository extends HiveRepositoryBase {
  PendingSyncRepository({required super.hiveService});

  static const String _boxName = 'pending_sync_operations';
  static const String _schemaNamespace = 'pending_sync_operations:v1';

  final StreamController<void> _enqueuedController =
      StreamController<void>.broadcast();

  @override
  String get boxName => _boxName;

  @override
  HiveBoxSchema? get schema => HiveBoxSchema(
    boxName: _boxName,
    namespace: _schemaNamespace,
    fingerprint:
        hiveSchemaFingerprints[_schemaNamespace] ??
        (throw StateError(
          'Missing hive schema fingerprint for $_schemaNamespace. '
          'Run: dart run tool/generate_hive_schema_fingerprints.dart',
        )),
    migrate: _migratePendingSyncOperations,
  );

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
  Future<void> markCompleted(final String operationId) =>
      markCompletedBody(operationId);

  /// Updates an operation that failed to sync with a new retry timestamp.
  Future<void> markFailed({
    required final String operationId,
    required final DateTime nextRetryAt,
    final int? retryCount,
  }) => markFailedBody(
    operationId: operationId,
    nextRetryAt: nextRetryAt,
    retryCount: retryCount,
  );

  /// Clears all pending operations from the queue.
  Future<void> clear() => clearBody();

  /// Prunes operations that have exceeded retry limits or are too old to retry.
  ///
  /// Returns the number of pruned operations.
  Future<int> prune({
    final int maxRetryCount = 10,
    final Duration maxAge = const Duration(days: 30),
  }) => pruneBody(maxRetryCount: maxRetryCount, maxAge: maxAge);
}
