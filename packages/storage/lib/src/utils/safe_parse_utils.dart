import 'package:app_shared_flutter/app_shared_flutter.dart';

String? stringFromDynamic(final dynamic value) => switch (value) {
  final String s => s,
  _ => null,
};

String? stringFromDynamicTrimmed(final dynamic value) {
  if (value is! String) return null;
  final String trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

int? intFromDynamic(final dynamic value) => switch (value) {
  null => null,
  final int v => v,
  final num v => v.toInt(),
  final String v => int.tryParse(v.trim()),
  _ => null,
};

double doubleFromDynamic(final dynamic value, final double fallback) =>
    switch (value) {
      null => fallback,
      final num v => v.toDouble(),
      final String v => double.tryParse(v) ?? fallback,
      _ => fallback,
    };

Map<String, dynamic>? mapFromDynamic(final dynamic value) => switch (value) {
  final Map<String, dynamic> map => map,
  final Map<Object?, Object?> map => Map<String, dynamic>.from(map),
  _ => null,
};

List<dynamic>? listFromDynamic(final dynamic value) => switch (value) {
  final List<dynamic> list => list,
  _ => null,
};

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
