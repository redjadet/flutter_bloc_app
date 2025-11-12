import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Helper functions for parsing and normalizing counter data from Hive storage.
class HiveCounterRepositoryHelpers {
  HiveCounterRepositoryHelpers._();

  /// Maximum allowed future timestamp offset (1 year).
  static const Duration _maxFutureOffset = Duration(days: 365);

  /// Parses and validates a timestamp value from Hive storage.
  ///
  /// Returns a valid [DateTime] if the timestamp is reasonable (non-negative,
  /// not too far in the future), otherwise returns `null`.
  static DateTime? parseTimestamp(final int? timestampMs) {
    if (timestampMs == null) {
      return null;
    }

    try {
      // Validate timestamp is reasonable (not negative, not too far in future)
      final int now = DateTime.now().millisecondsSinceEpoch;
      final int maxFuture = now + _maxFutureOffset.inMilliseconds;

      if (timestampMs >= 0 && timestampMs <= maxFuture) {
        return DateTime.fromMillisecondsSinceEpoch(timestampMs);
      }

      AppLogger.warning(
        'Invalid timestamp in Hive: $timestampMs, ignoring',
      );
      return null;
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'Failed to parse timestamp from Hive: $timestampMs',
        error,
        stackTrace,
      );
      return null;
    }
  }

  /// Normalizes a counter snapshot, ensuring it has a valid userId.
  ///
  /// If the snapshot is empty (null userId, count 0, no lastChanged), returns
  /// the empty snapshot. Otherwise ensures userId is set to the local user ID.
  static CounterSnapshot normalizeSnapshot(
    final CounterSnapshot snapshot,
    final CounterSnapshot emptySnapshot,
    final String localUserId,
  ) {
    if (snapshot.userId == null &&
        snapshot.count == 0 &&
        snapshot.lastChanged == null) {
      return emptySnapshot;
    }
    return snapshot.userId != null
        ? snapshot
        : snapshot.copyWith(userId: localUserId);
  }
}
