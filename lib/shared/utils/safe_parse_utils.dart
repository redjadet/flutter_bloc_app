/// Centralized safe parsing from dynamic / JSON-like values.
///
/// Use for repository and mapper code that reads from [Map]/JSON/snapshots
/// without assuming types. Prefer these over ad-hoc casts to avoid silent
/// misuse of data.
library;

import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Returns [value] as [String] if it is a [String], otherwise null.
String? stringFromDynamic(final dynamic value) => switch (value) {
  final String s => s,
  _ => null,
};

/// Returns trimmed [value] as [String], or null if not a string or empty.
String? stringFromDynamicTrimmed(final dynamic value) {
  if (value is! String) return null;
  final String trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Returns [value] as [int] if possible (int, num, or parseable String).
int? intFromDynamic(final dynamic value) => switch (value) {
  null => null,
  final int v => v,
  final num v => v.toInt(),
  final String v => int.tryParse(v.trim()),
  _ => null,
};

/// Returns [value] as [double], or [fallback] if null/not parseable.
double doubleFromDynamic(final dynamic value, final double fallback) =>
    switch (value) {
      null => fallback,
      final num v => v.toDouble(),
      final String v => double.tryParse(v) ?? fallback,
      _ => fallback,
    };

/// Returns [value] as [Map<String, dynamic>], or null if not a map.
Map<String, dynamic>? mapFromDynamic(final dynamic value) => switch (value) {
  final Map<String, dynamic> map => map,
  final Map<Object?, Object?> map => Map<String, dynamic>.from(map),
  _ => null,
};

/// Returns [value] as [List], or null if not a list.
List<dynamic>? listFromDynamic(final dynamic value) => switch (value) {
  final List<dynamic> list => list,
  _ => null,
};

/// Returns [value] as [bool] if possible, or [fallback] when not parseable.
///
/// Accepted truthy values: `true`, non-zero numbers, `'true'`, `'1'`.
/// Accepted falsy values: `false`, zero numbers, `'false'`, `'0'`.
bool boolFromDynamic(final dynamic value, {required final bool fallback}) =>
    switch (value) {
      null => fallback,
      final bool v => v,
      final num v => v != 0,
      final String v => switch (v.trim().toLowerCase()) {
        'true' || '1' => true,
        'false' || '0' => false,
        _ => fallback,
      },
      _ => fallback,
    };

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
