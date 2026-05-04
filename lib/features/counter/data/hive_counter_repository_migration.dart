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

  int? _coerceCount(final dynamic raw) {
    if (raw is int) {
      return raw < 0 ? 0 : raw;
    }
    if (raw is num) {
      if (!raw.isFinite) return null;
      final int v = raw.toInt();
      return v < 0 ? 0 : v;
    }
    if (raw is String) {
      final int? v = int.tryParse(raw.trim());
      if (v == null) return null;
      return v < 0 ? 0 : v;
    }
    return null;
  }

  int? _coerceTimestampMs(final dynamic raw) {
    int? timestampMs;
    if (raw is int) {
      timestampMs = raw;
    } else if (raw is num) {
      if (!raw.isFinite) return null;
      timestampMs = raw.toInt();
    } else if (raw is String && raw.trim().isNotEmpty) {
      final String trimmed = raw.trim();
      final int? asInt = int.tryParse(trimmed);
      if (asInt != null) {
        timestampMs = asInt;
      } else {
        final DateTime? parsed = DateTime.tryParse(trimmed);
        timestampMs = parsed?.toUtc().millisecondsSinceEpoch;
      }
    } else if (raw is DateTime) {
      timestampMs = raw.toUtc().millisecondsSinceEpoch;
    }

    if (timestampMs == null) {
      return null;
    }
    return HiveCounterRepositoryHelpers.parseTimestamp(
      timestampMs,
    )?.millisecondsSinceEpoch;
  }

  bool? _coerceBool(final dynamic raw) {
    if (raw is bool) return raw;
    if (raw is int) {
      if (raw == 0) return false;
      if (raw == 1) return true;
      return null;
    }
    if (raw is num) {
      final int v = raw.toInt();
      if (v == 0) return false;
      if (v == 1) return true;
      return null;
    }
    if (raw is String && raw.isNotEmpty) {
      final String normalized = raw.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
      if (normalized == '0') return false;
      if (normalized == '1') return true;
      return null;
    }
    return null;
  }

  String? _coerceNonEmptyString(final dynamic raw) {
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return null;
  }
}
