/// Centralized safe parsing from dynamic / JSON-like values.
///
/// Use for repository and mapper code that reads from [Map]/JSON/snapshots
/// without assuming types. Prefer these over ad-hoc casts to avoid silent
/// misuse of data.
library;

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
