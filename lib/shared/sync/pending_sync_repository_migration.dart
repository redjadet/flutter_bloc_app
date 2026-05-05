part of 'pending_sync_repository.dart';

typedef _DeadLetterPayload = Map<String, dynamic>;

const String _deadLetterSchema = 'dead_letter:v1';
const String _deadLetterPrefix = 'dead_letter:';

Future<void> _migratePendingSyncOperations(
  final Box<dynamic> box, {
  required final String? fromFingerprint,
}) async {
  final Map<dynamic, dynamic> entries = box.toMap();

  for (final MapEntry<dynamic, dynamic> entry in entries.entries) {
    final dynamic key = entry.key;
    if (key == HiveSchemaMigratorService.metaKeyFingerprints) {
      continue;
    }
    if (key is String && key.startsWith(_deadLetterPrefix)) {
      continue;
    }

    final dynamic value = entry.value;
    final _LegacyValidationResult validation = _validateLegacyOperation(value);
    if (validation.isValid) {
      continue;
    }

    final String deadLetterKey = '$_deadLetterPrefix$key';
    final dynamic existingDeadLetter = box.get(deadLetterKey);
    if (existingDeadLetter == null) {
      final _DeadLetterPayload payload = _buildDeadLetterPayload(
        originalKey: key,
        originalValue: value,
        error: validation.error,
        fromFingerprint: fromFingerprint,
      );
      await box.put(deadLetterKey, payload);
    }

    // Delete only after quarantine write succeeded (or already existed).
    await box.delete(key);
  }
}

final class _LegacyValidationResult {
  const _LegacyValidationResult({required this.isValid, required this.error});

  const _LegacyValidationResult.valid() : this(isValid: true, error: null);

  const _LegacyValidationResult.invalid(final String error)
    : this(isValid: false, error: error);

  final bool isValid;
  final String? error;
}

_LegacyValidationResult _validateLegacyOperation(final dynamic value) {
  if (value is! Map<dynamic, dynamic>) {
    return const _LegacyValidationResult.invalid('value_not_map');
  }

  final SyncOperation? operation = _operationFromJsonOrNullMigrator(value);
  if (operation == null) {
    return const _LegacyValidationResult.invalid('sync_operation_parse_failed');
  }

  if (operation.id.trim().isEmpty) {
    return const _LegacyValidationResult.invalid('missing_id');
  }
  if (operation.entityType.trim().isEmpty) {
    return const _LegacyValidationResult.invalid('missing_entity_type');
  }
  if (operation.idempotencyKey.trim().isEmpty) {
    return const _LegacyValidationResult.invalid('missing_idempotency_key');
  }
  if (operation.retryCount < 0) {
    return const _LegacyValidationResult.invalid('negative_retry_count');
  }

  // Runtime contract: iot_demo is user-scoped. Legacy ops without user id are
  // excluded under user filtering and are unsafe to keep.
  if (operation.entityType == 'iot_demo') {
    final dynamic uid =
        operation.payload[PendingSyncRepository.payloadKeySupabaseUserId];
    if (uid is! String || uid.trim().isEmpty) {
      return const _LegacyValidationResult.invalid('iot_demo_missing_user_id');
    }
  }

  return const _LegacyValidationResult.valid();
}

_DeadLetterPayload _buildDeadLetterPayload({
  required final dynamic originalKey,
  required final dynamic originalValue,
  required final String? error,
  required final String? fromFingerprint,
}) {
  return <String, dynamic>{
    'schema': _deadLetterSchema,
    'quarantinedAt': DateTime.now().toUtc().toIso8601String(),
    'originalKey': originalKey.toString(),
    'fromFingerprint': fromFingerprint,
    'error': error,
    'originalValue': _deadLetterOriginalValue(originalValue),
  };
}

dynamic _deadLetterOriginalValue(final dynamic originalValue) {
  if (originalValue is Map<dynamic, dynamic>) {
    return _convertMapToTypedMigrator(originalValue);
  }
  if (originalValue is List<dynamic>) {
    return _convertListToTypedMigrator(originalValue);
  }
  return originalValue;
}

SyncOperation? _operationFromJsonOrNullMigrator(
  final Map<dynamic, dynamic> json,
) {
  final Map<String, dynamic> converted = _convertMapToTypedMigrator(json);
  try {
    return SyncOperation.fromJson(converted);
  } on Object {
    return null;
  }
}

Map<String, dynamic> _convertMapToTypedMigrator(
  final Map<dynamic, dynamic> source,
) {
  final Map<String, dynamic> result = <String, dynamic>{};
  for (final MapEntry<dynamic, dynamic> entry in source.entries) {
    if (entry.key is! String) {
      continue;
    }

    final String key = entry.key as String;
    final dynamic value = entry.value;

    if (value is Map<dynamic, dynamic>) {
      result[key] = _convertMapToTypedMigrator(value);
      continue;
    }

    if (value is List<dynamic>) {
      result[key] = _convertListToTypedMigrator(value);
      continue;
    }

    result[key] = value;
  }
  return result;
}

List<dynamic> _convertListToTypedMigrator(final List<dynamic> source) {
  return source
      .map((final dynamic item) {
        if (item is Map<dynamic, dynamic>) {
          return _convertMapToTypedMigrator(item);
        }
        return item;
      })
      .toList(growable: false);
}
