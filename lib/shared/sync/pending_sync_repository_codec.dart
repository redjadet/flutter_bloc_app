part of 'pending_sync_repository.dart';

class _PendingOperationsReadResult {
  const _PendingOperationsReadResult({
    required this.operations,
    required this.malformedKeys,
  });

  final List<_StoredPendingOperation> operations;
  final List<dynamic> malformedKeys;
}

class _StoredPendingOperation {
  const _StoredPendingOperation({
    required this.key,
    required this.operation,
  });

  final dynamic key;
  final SyncOperation operation;
}

extension on PendingSyncRepository {
  _PendingOperationsReadResult _readOperations(
    final Map<dynamic, dynamic> entries,
  ) {
    final List<dynamic> malformedKeys = <dynamic>[];
    final List<_StoredPendingOperation> operations =
        <_StoredPendingOperation>[];

    for (final MapEntry<dynamic, dynamic> entry in entries.entries) {
      final dynamic value = entry.value;
      if (value is! Map<dynamic, dynamic>) {
        malformedKeys.add(entry.key);
        continue;
      }

      final SyncOperation? operation = _operationFromJsonOrNull(value);
      if (operation == null) {
        malformedKeys.add(entry.key);
        continue;
      }

      operations.add(
        _StoredPendingOperation(
          key: entry.key,
          operation: operation,
        ),
      );
    }

    return _PendingOperationsReadResult(
      operations: operations,
      malformedKeys: malformedKeys,
    );
  }

  Future<void> _deleteKeys(
    final Box<dynamic> box,
    final Iterable<dynamic> keys,
  ) async {
    for (final dynamic key in keys) {
      await box.delete(key);
    }
  }

  bool _isReadyForRetry(
    final SyncOperation operation,
    final DateTime threshold,
  ) {
    return switch (operation.nextRetryAt) {
      final nextRetryAt? => !nextRetryAt.isAfter(threshold),
      _ => true,
    };
  }

  bool _matchesSupabaseUserIdFilter(
    final SyncOperation operation,
    final String supabaseUserIdFilter,
  ) {
    if (operation.entityType != 'iot_demo') {
      return true;
    }
    final dynamic uid =
        operation.payload[PendingSyncRepository.payloadKeySupabaseUserId];
    return uid == supabaseUserIdFilter;
  }

  bool _isOlderThanCutoff(
    final SyncOperation operation,
    final DateTime cutoff,
  ) {
    return switch (operation.nextRetryAt) {
      final nextRetryAt? => nextRetryAt.isBefore(cutoff),
      _ => false,
    };
  }

  // When reading from a Hive box with no explicit type, the map keys
  // are dynamic. We need to recursively convert to Map<String, dynamic>.
  /// Returns null when the stored map is malformed (log and skip).
  SyncOperation? _operationFromJsonOrNull(final Map<dynamic, dynamic> json) {
    final Map<String, dynamic> converted = _convertMapToTyped(json);
    try {
      return SyncOperation.fromJson(converted);
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'PendingSyncRepository: malformed stored operation',
        error,
        stackTrace,
      );
      return null;
    }
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
        result[key] = _convertMapToTyped(value);
        continue;
      }

      if (value is List<dynamic>) {
        result[key] = _convertListToTyped(value);
        continue;
      }

      result[key] = value;
    }
    return result;
  }

  List<dynamic> _convertListToTyped(final List<dynamic> source) {
    return source
        .map((final dynamic item) {
          if (item is Map<dynamic, dynamic>) {
            return _convertMapToTyped(item);
          }
          return item;
        })
        .toList(growable: false);
  }
}
