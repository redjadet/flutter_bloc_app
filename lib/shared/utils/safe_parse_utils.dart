/// Centralized safe parsing from dynamic / JSON-like values.
///
/// Use for repository and mapper code that reads from [Map]/JSON/snapshots
/// without assuming types. Prefer these over ad-hoc casts to avoid silent
/// misuse of data.
library;

/// Returns [value] as [String] if it is a [String], otherwise null.
String? stringFromDynamic(final dynamic value) => value is String ? value : null;

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
