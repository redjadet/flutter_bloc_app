import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

/// Helper functions for data migration validation and normalization.
///
/// Provides utilities for safely converting and validating data during
/// migration from SharedPreferences to Hive.
class MigrationHelpers {
  MigrationHelpers._();

  /// Maximum allowed future timestamp offset (1 year).
  static const Duration _maxFutureOffset = Duration(days: 365);

  /// Validates and normalizes a count value from SharedPreferences.
  ///
  /// Handles type conversion and ensures the result is non-negative.
  ///
  /// Returns:
  /// - The normalized count value (non-negative integer)
  /// - `null` if the value cannot be converted to a number
  ///
  /// Examples:
  /// - `5` → `5`
  /// - `-3` → `0` (negative values normalized to 0)
  /// - `3.7` → `3` (floats truncated)
  /// - `'invalid'` → `null`
  static int? normalizeCount(final dynamic value) {
    final int? raw = intFromDynamic(value);
    if (raw == null) return null;
    return raw >= 0 ? raw : 0;
  }

  /// Validates and normalizes a timestamp value from SharedPreferences.
  ///
  /// Ensures the timestamp is:
  /// - Non-negative
  /// - Not more than [_maxFutureOffset] in the future
  ///
  /// Returns:
  /// - The normalized timestamp in milliseconds since epoch
  /// - `null` if the timestamp is invalid or cannot be converted
  ///
  /// Invalid timestamps are logged as warnings.
  static int? normalizeTimestamp(final dynamic value) {
    final int? timestamp = intFromDynamic(value);

    if (timestamp == null) {
      return null;
    }

    // Validate timestamp is reasonable (not negative, not too far in future)
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int maxFuture = now + _maxFutureOffset.inMilliseconds;

    if (timestamp >= 0 && timestamp <= maxFuture) {
      return timestamp;
    }

    AppLogger.warning(
      'Invalid timestamp in SharedPreferences: $timestamp, skipping',
    );
    return null;
  }
}
