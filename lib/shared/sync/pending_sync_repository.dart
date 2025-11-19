import 'dart:async';

import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PendingSyncRepository extends HiveRepositoryBase {
  PendingSyncRepository({required super.hiveService});

  static const String _boxName = 'pending_sync_operations';

  @override
  String get boxName => _boxName;

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

  Future<List<SyncOperation>> getPendingOperations({
    DateTime? now,
    int? limit,
  }) async => StorageGuard.run<List<SyncOperation>>(
    logContext: 'PendingSyncRepository.getPendingOperations',
    action: () async {
      final Box<dynamic> box = await getBox();
      final List<SyncOperation> operations =
          box.values
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (final Map<dynamic, dynamic> raw) => SyncOperation.fromJson(
                  Map<String, dynamic>.from(
                    raw.map(
                      (final dynamic key, final dynamic value) =>
                          MapEntry(key.toString(), value),
                    ),
                  ),
                ),
              )
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

  Future<void> markCompleted(final String operationId) async {
    await StorageGuard.run<void>(
      logContext: 'PendingSyncRepository.markCompleted',
      action: () async {
        final Box<dynamic> box = await getBox();
        await box.delete(operationId);
      },
    );
  }

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
        if (stored is! Map) {
          return;
        }
        final Map<dynamic, dynamic> raw = Map<dynamic, dynamic>.from(stored);
        final SyncOperation existing = SyncOperation.fromJson(
          Map<String, dynamic>.from(
            raw.map(
              (final dynamic key, final dynamic value) =>
                  MapEntry(key.toString(), value),
            ),
          ),
        );
        final SyncOperation updated = existing.copyWith(
          nextRetryAt: nextRetryAt,
          retryCount: retryCount ?? (existing.retryCount + 1),
        );
        await box.put(operationId, updated.toJson());
      },
    );
  }

  Future<void> clear() async {
    await StorageGuard.run<void>(
      logContext: 'PendingSyncRepository.clear',
      action: () async {
        final Box<dynamic> box = await getBox();
        await box.clear();
      },
    );
  }
}
