import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_item.freezed.dart';

enum TodoPriority { none, low, medium, high }

@freezed
abstract class TodoItem with _$TodoItem {
  const factory TodoItem({
    required final String id,
    required final String title,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? description,
    @Default(false) final bool isCompleted,
    final DateTime? dueDate,
    @Default(TodoPriority.none) final TodoPriority priority,
  }) = _TodoItem;

  const TodoItem._();

  factory TodoItem.create({
    required final String title,
    final String? description,
    final DateTime? dueDate,
    final TodoPriority priority = TodoPriority.none,
    final DateTime? now,
  }) {
    final DateTime timestamp = (now ?? DateTime.now()).toUtc();
    return TodoItem(
      id: _TodoIdGenerator.instance.generate(),
      title: title,
      description: description,
      createdAt: timestamp,
      updatedAt: timestamp,
      dueDate: dueDate?.toUtc(),
      priority: priority,
    );
  }

  bool get isOverdue {
    if (isCompleted || dueDate == null) {
      return false;
    }
    final DateTime nowLocal = DateTime.now();
    final DateTime todayLocal = DateTime(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day,
    );
    final DateTime dueLocal = dueDate!.toLocal();
    final DateTime dueDateOnly = DateTime(
      dueLocal.year,
      dueLocal.month,
      dueLocal.day,
    );
    return dueDateOnly.isBefore(todayLocal);
  }

  int get priorityValue => switch (priority) {
    TodoPriority.none => 0,
    TodoPriority.low => 1,
    TodoPriority.medium => 2,
    TodoPriority.high => 3,
  };
}

class _TodoIdGenerator {
  _TodoIdGenerator._();

  static final _TodoIdGenerator instance = _TodoIdGenerator._();
  final math.Random _random = math.Random();

  String generate() {
    final int timestamp = DateTime.now().microsecondsSinceEpoch;
    final int entropy = _random.nextInt(1 << 32);
    return '$timestamp-$entropy';
  }
}
