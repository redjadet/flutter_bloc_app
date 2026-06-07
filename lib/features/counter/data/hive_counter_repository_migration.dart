part of 'hive_counter_repository.dart';

extension HiveCounterRepositoryMigration on HiveCounterRepository {
  Future<void> _migrateCounter(
    final Box<dynamic> box, {
    required final String? fromFingerprint,
  }) async {
    final int? migratedCount = _coerceCount(
      box.get(HiveCounterRepository._keyCount),
    );
    if (migratedCount == null) {
      await box.delete(HiveCounterRepository._keyCount);
    } else {
      await box.put(HiveCounterRepository._keyCount, migratedCount);
    }

    final int? changedMs = _coerceTimestampMs(
      box.get(HiveCounterRepository._keyChanged),
    );
    if (changedMs == null) {
      await box.delete(HiveCounterRepository._keyChanged);
    } else {
      await box.put(HiveCounterRepository._keyChanged, changedMs);
    }

    final int? syncedMs = _coerceTimestampMs(
      box.get(HiveCounterRepository._keyLastSynced),
    );
    if (syncedMs == null) {
      await box.delete(HiveCounterRepository._keyLastSynced);
    } else {
      await box.put(HiveCounterRepository._keyLastSynced, syncedMs);
    }

    final bool? synchronized = _coerceBool(
      box.get(HiveCounterRepository._keySynchronized),
    );
    if (synchronized == null) {
      await box.delete(HiveCounterRepository._keySynchronized);
    } else {
      await box.put(HiveCounterRepository._keySynchronized, synchronized);
    }

    final String? userId = _coerceNonEmptyString(
      box.get(HiveCounterRepository._keyUserId),
    );
    if (userId == null) {
      await box.delete(HiveCounterRepository._keyUserId);
    } else {
      await box.put(HiveCounterRepository._keyUserId, userId);
    }

    final String? changeId = _coerceNonEmptyString(
      box.get(HiveCounterRepository._keyChangeId),
    );
    if (changeId == null) {
      await box.delete(HiveCounterRepository._keyChangeId);
    } else {
      await box.put(HiveCounterRepository._keyChangeId, changeId);
    }
  }

  int? _coerceCount(final dynamic raw) => switch (raw) {
    final int v => v < 0 ? 0 : v,
    final num v when !v.isFinite => null,
    final num v => _nonNegativeInt(v.toInt()),
    final String v => _nonNegativeInt(int.tryParse(v.trim())),
    _ => null,
  };

  int? _nonNegativeInt(final int? value) {
    if (value == null) {
      return null;
    }
    return value < 0 ? 0 : value;
  }

  int? _coerceTimestampMs(final dynamic raw) {
    final int? timestampMs = switch (raw) {
      final int v => v,
      final num v when !v.isFinite => null,
      final num v => v.toInt(),
      final String v when v.trim().isEmpty => null,
      final String v =>
        int.tryParse(v.trim()) ??
            DateTime.tryParse(v.trim())?.toUtc().millisecondsSinceEpoch,
      final DateTime v => v.toUtc().millisecondsSinceEpoch,
      _ => null,
    };

    if (timestampMs == null) {
      return null;
    }
    return HiveCounterRepositoryHelpers.parseTimestamp(
      timestampMs,
    )?.millisecondsSinceEpoch;
  }

  bool? _coerceBool(final dynamic raw) => switch (raw) {
    final bool v => v,
    final int v when v == 0 => false,
    final int v when v == 1 => true,
    final num v when v.toInt() == 0 => false,
    final num v when v.toInt() == 1 => true,
    final String v when v.isEmpty => null,
    final String v => switch (v.trim().toLowerCase()) {
      'true' || '1' => true,
      'false' || '0' => false,
      _ => null,
    },
    _ => null,
  };

  String? _coerceNonEmptyString(final dynamic raw) => switch (raw) {
    final String v when v.trim().isNotEmpty => v.trim(),
    _ => null,
  };
}
