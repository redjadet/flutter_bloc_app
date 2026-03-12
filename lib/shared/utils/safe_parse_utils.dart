/// Centralized safe parsing from dynamic / JSON-like values.
///
/// Use for repository and mapper code that reads from [Map]/JSON/snapshots
/// without assuming types. Prefer these over ad-hoc casts to avoid silent
/// misuse of data.
library;

import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Returns [value] as [String] if it is a [String], otherwise null.
String? stringFromDynamic(final dynamic value) =>
    value is String ? value : null;

/// Returns trimmed [value] as [String], or null if not a string or empty.
String? stringFromDynamicTrimmed(final dynamic value) {
  if (value is! String) return null;
  final String trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Returns [value] as [int] if possible (int, num, or parseable String).
int? intFromDynamic(final dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

/// Returns [value] as [double], or [fallback] if null/not parseable.
double doubleFromDynamic(final dynamic value, final double fallback) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

/// Returns [value] as [Map<String, dynamic>], or null if not a map.
Map<String, dynamic>? mapFromDynamic(final dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

/// Returns [value] as [List], or null if not a list.
List<dynamic>? listFromDynamic(final dynamic value) {
  if (value is List) return value;
  return null;
}

/// Returns [value] as [bool] if possible, or [fallback] when not parseable.
///
/// Accepted truthy values: `true`, non-zero numbers, `'true'`, `'1'`.
/// Accepted falsy values: `false`, zero numbers, `'false'`, `'0'`.
bool boolFromDynamic(final dynamic value, {required final bool fallback}) {
  if (value == null) {
    return fallback;
  }
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final String normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }
  }
  return fallback;
}

/// Parses a map-of-maps (e.g. Realtime DB snapshot) into a list of [T] by
/// calling [parseItem] for each map value. Skips non-map values and entries
/// that throw or return null; logs parse failures with [logContext].
List<T> parseMapOfMaps<T>(
  final Object? value, {
  required final T? Function(Object? key, Map<dynamic, dynamic> map) parseItem,
  required final String logContext,
}) {
  if (value == null) {
    return <T>[];
  }
  if (value is! Map) {
    AppLogger.warning(
      '$logContext unexpected payload type: ${value.runtimeType}',
    );
    return <T>[];
  }
  final Map<Object?, Object?> data = Map<Object?, Object?>.from(value);
  final List<T> out = <T>[];
  for (final MapEntry<Object?, Object?> entry in data.entries) {
    final Object? v = entry.value;
    if (v is! Map) {
      continue;
    }
    try {
      final Map<dynamic, dynamic> itemMap = Map<dynamic, dynamic>.from(v);
      final T? item = parseItem(entry.key, itemMap);
      if (item != null) {
        out.add(item);
      }
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        '$logContext failed to parse item: ${entry.key}',
        error,
        stackTrace,
      );
    }
  }
  return out;
}
