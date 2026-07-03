part of 'hive_todo_repository.dart';

extension HiveTodoRepositoryMigration on HiveTodoRepository {
  Future<void> _migrateTodos(
    final Box<dynamic> box, {
    required final String? fromFingerprint,
  }) async {
    // Best-effort: never leave tmp key around.
    await safeDeleteKey(box, HiveTodoRepository._tmpKeyMigrated);

    final dynamic raw = box.get(HiveTodoRepository._keyTodos);
    final List<dynamic>? rawList = await _decodeTodosRawToListOrNull(raw);
    if (rawList == null) {
      // Unknown shape: drop the whole key. (Cannot salvage safely.)
      await safeDeleteKey(box, HiveTodoRepository._keyTodos);
      return;
    }

    final List<Map<String, dynamic>> migrated = <Map<String, dynamic>>[];
    for (final dynamic item in rawList) {
      if (item is! Map<dynamic, dynamic>) {
        continue;
      }
      final Map<String, dynamic>? salvaged = _salvageTodoMap(item);
      if (salvaged == null) {
        continue;
      }
      migrated.add(salvaged);
    }

    // Two-phase write: tmp -> validate -> swap.
    await box.put(HiveTodoRepository._tmpKeyMigrated, migrated);

    final dynamic tmpRaw = box.get(HiveTodoRepository._tmpKeyMigrated);
    if (tmpRaw is! Iterable<dynamic>) {
      await safeDeleteKey(box, HiveTodoRepository._tmpKeyMigrated);
      throw const FormatException('Todo migration tmp payload invalid');
    }

    for (final dynamic entry in tmpRaw) {
      if (entry is! Map<dynamic, dynamic>) {
        await safeDeleteKey(box, HiveTodoRepository._tmpKeyMigrated);
        throw const FormatException('Todo migration tmp item invalid');
      }
      // Validation: should not throw.
      TodoItemDto.fromMap(entry);
    }

    if (migrated.isEmpty) {
      await safeDeleteKey(box, HiveTodoRepository._keyTodos);
    } else {
      await box.put(HiveTodoRepository._keyTodos, migrated);
    }
    await safeDeleteKey(box, HiveTodoRepository._tmpKeyMigrated);
  }

  Future<List<dynamic>?> _decodeTodosRawToListOrNull(final dynamic raw) async {
    if (raw == null) {
      return const <dynamic>[];
    }
    if (raw is String) {
      if (raw.isEmpty) {
        return const <dynamic>[];
      }
      try {
        final List<dynamic> decoded = await decodeJsonList(raw);
        return decoded;
      } on Object {
        return null;
      }
    }
    if (raw is Iterable<dynamic>) {
      return raw.toList(growable: false);
    }
    return null;
  }

  Map<String, dynamic>? _salvageTodoMap(final Map<dynamic, dynamic> raw) {
    final Map<String, dynamic> out = raw.map(
      (final dynamic key, final dynamic value) =>
          MapEntry(key.toString(), value),
    );

    final String? id = out['id']?.toString();
    final String? title = out['title']?.toString();
    if (id == null || id.isEmpty || title == null || title.isEmpty) {
      return null;
    }

    final String? createdAtIso = _coerceDateToUtcIso(out['createdAt']);
    final String? updatedAtIso = _coerceDateToUtcIso(out['updatedAt']);
    if (createdAtIso == null || updatedAtIso == null) {
      return null;
    }
    out['createdAt'] = createdAtIso;
    out['updatedAt'] = updatedAtIso;

    if (out.containsKey('dueDate')) {
      final String? due = _coerceDateToUtcIso(out['dueDate']);
      if (due == null) {
        out.remove('dueDate');
      } else {
        out['dueDate'] = due;
      }
    }
    if (out.containsKey('lastSyncedAt')) {
      final String? last = _coerceDateToUtcIso(out['lastSyncedAt']);
      if (last == null) {
        out.remove('lastSyncedAt');
      } else {
        out['lastSyncedAt'] = last;
      }
    }

    // Keep other fields as-is; TodoItemDto.fromMap applies bool/priority coercions.
    return out;
  }

  String? _coerceDateToUtcIso(final dynamic value) {
    try {
      if (value is DateTime) {
        return value.toUtc().toIso8601String();
      }
      if (value is String && value.trim().isNotEmpty) {
        final String trimmed = value.trim();
        final DateTime? parsed = DateTime.tryParse(trimmed);
        if (parsed != null) {
          return parsed.toUtc().toIso8601String();
        }
        final int? ms = int.tryParse(trimmed);
        if (ms != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            ms,
            isUtc: true,
          ).toUtc().toIso8601String();
        }
        return null;
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(
          value,
          isUtc: true,
        ).toUtc().toIso8601String();
      }
      if (value is num) {
        if (!value.isFinite) return null;
        return DateTime.fromMillisecondsSinceEpoch(
          value.toInt(),
          isUtc: true,
        ).toUtc().toIso8601String();
      }
    } on Object {
      return null;
    }
    return null;
  }
}
