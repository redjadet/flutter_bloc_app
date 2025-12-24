import 'dart:async';

import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A repository for managing a queue of [SyncOperation]s that need to be
/// processed and synchronized with a remote backend.
///
/// It uses Hive for persistent, encrypted storage.
class PendingSyncRepository extends HiveRepositoryBase {
  PendingSyncRepository({required super.hiveService});

  static const String _boxName = 'pending_sync_operations';

  @override
  String get boxName => _boxName;

  /// Adds a [SyncOperation] to the pending queue.
  Future<SyncOperation> enqueue(final SyncOperation operation) async {
    await StorageGuard.run<void>(
      logContext: 'PendingSyncRepository.enqueue',
      action: () async {
        final Box<dynamic> box = await getBox();
        await box.put(operation.id, operation.toJson());
      },
    );
    return operation;
  }

  /// Retrieves a list of pending [SyncOperation]s that are ready to be retried.
  ///
  /// Operations are sorted by their creation time.
  /// The [now] parameter can be used to deterministically filter operations
  /// based on their `nextRetryAt` timestamp, which is useful for testing.
  /// The [limit] parameter can be used to control the batch size.
  Future<List<SyncOperation>> getPendingOperations({
    final DateTime? now,
    final int? limit,
  }) async => StorageGuard.run<List<SyncOperation>>(
    logContext: 'PendingSyncRepository.getPendingOperations',
    action: () async {
      final Box<dynamic> box = await getBox();
      final List<SyncOperation> operations =
          box.values
              .whereType<Map<dynamic, dynamic>>()
              .map(_operationFromJson)
              .toList(growable: false)
            ..sort(
              (final SyncOperation a, final SyncOperation b) =>
                  a.createdAt.compareTo(b.createdAt),
            );

      final DateTime threshold = (now ?? DateTime.now()).toUtc();
      final Iterable<SyncOperation> ready = operations.where(
        (final SyncOperation op) =>
            op.nextRetryAt == null || !op.nextRetryAt!.isAfter(threshold),
      );

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
          return;
        }

        final SyncOperation existing = _operationFromJson(stored);
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
      final List<dynamic> keysToDelete = <dynamic>[];
      for (final MapEntry<dynamic, dynamic> entry in box.toMap().entries) {
        final dynamic value = entry.value;
        if (value is! Map<dynamic, dynamic>) {
          continue;
        }
        final SyncOperation op = _operationFromJson(value);
        final bool tooManyRetries = op.retryCount >= maxRetryCount;
        final bool tooOld =
            op.nextRetryAt != null && op.nextRetryAt!.isBefore(cutoff);
        if (tooManyRetries || tooOld) {
          keysToDelete.add(entry.key);
        }
      }
      for (final dynamic key in keysToDelete) {
        await box.delete(key);
      }
      return keysToDelete.length;
    },
    fallback: () => 0,
  );

  // When reading from a Hive box with no explicit type, the map keys
  // are dynamic. We need to recursively convert to Map<String, dynamic>.
  SyncOperation _operationFromJson(final Map<dynamic, dynamic> json) {
    final Map<String, dynamic> converted = <String, dynamic>{};
    for (final MapEntry<dynamic, dynamic> entry in json.entries) {
      if (entry.key is! String) {
        continue;
      }
      final String key = entry.key as String;
      final dynamic value = entry.value;

      if (value is Map<dynamic, dynamic>) {
        // Recursively convert nested maps (e.g., payload field)
        converted[key] = _convertMapToTyped(value);
      } else if (value is List<dynamic>) {
        // Convert lists that may contain maps
        converted[key] = value.map((final dynamic item) {
          if (item is Map<dynamic, dynamic>) {
            return _convertMapToTyped(item);
          }
          return item;
        }).toList();
      } else {
        // Primitive values can be copied directly
        converted[key] = value;
      }
    }
    return SyncOperation.fromJson(converted);
  }

  /// Recursively converts `Map<dynamic, dynamic>` to `Map<String, dynamic>`.
  /// Handles nested maps and lists that may contain maps.
  Map<String, dynamic> _convertMapToTyped(final Map<dynamic, dynamic> source) {
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final MapEntry<dynamic, dynamic> entry in source.entries) {
      if (entry.key is! String) {
        continue;
      }
      final String key = entry.key as String;
      final dynamic value = entry.value;

      if (value is Map<dynamic, dynamic>) {
        // Recursively convert nested maps
        result[key] = _convertMapToTyped(value);
      } else if (value is List<dynamic>) {
        // Convert lists that may contain maps
        result[key] = value.map((final dynamic item) {
          if (item is Map<dynamic, dynamic>) {
            return _convertMapToTyped(item);
          }
          return item;
        }).toList();
      } else {
        // Primitive values can be copied directly
        result[key] = value;
      }
    }
    return result;
  }
}
