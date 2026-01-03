import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';

class TodoItemDto {
  TodoItemDto({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  TodoItemDto.fromDomain(final TodoItem item)
    : id = item.id,
      title = item.title,
      description = item.description,
      isCompleted = item.isCompleted,
      createdAt = item.createdAt,
      updatedAt = item.updatedAt;

  factory TodoItemDto.fromMap(final Map<dynamic, dynamic> raw) {
    final Map<String, dynamic> normalized = raw.map(
      (final dynamic key, final dynamic value) =>
          MapEntry(key.toString(), value),
    );
    final String? id = normalized['id'] as String?;
    final String? title = normalized['title'] as String?;
    if (id == null || id.isEmpty || title == null || title.isEmpty) {
      throw const FormatException('Invalid TodoItem payload');
    }
    final String? description = normalized['description'] as String?;
    final bool isCompleted = _coerceBool(normalized['isCompleted']);
    final DateTime? createdAt = _parseDate(normalized['createdAt']);
    final DateTime? updatedAt = _parseDate(normalized['updatedAt']);
    if (createdAt == null || updatedAt == null) {
      throw const FormatException('Invalid TodoItem payload');
    }
    return TodoItemDto(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoItem toDomain() => TodoItem(
    id: id,
    title: title,
    description: description,
    isCompleted: isCompleted,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  static bool _coerceBool(final dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  static DateTime? _parseDate(final dynamic value) {
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }
}
