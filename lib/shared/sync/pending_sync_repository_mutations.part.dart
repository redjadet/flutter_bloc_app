part of 'pending_sync_repository.dart';

extension _PendingSyncRepositoryMutations on PendingSyncRepository {
  Future<void> markCompletedBody(final String operationId) async {
    await StorageGuard.run<void>(
      logContext: 'PendingSyncRepository.markCompleted',
      action: () async {
        final Box<dynamic> box = await getBox();
        await box.delete(operationId);
      },
    );
  }

  Future<void> markFailedBody({
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

  Future<void> clearBody() async {
    await StorageGuard.run<void>(
      logContext: 'PendingSyncRepository.clear',
      action: () async {
        final Box<dynamic> box = await getBox();
        await box.clear();
      },
    );
  }

  Future<int> pruneBody({
    required final int maxRetryCount,
    required final Duration maxAge,
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
