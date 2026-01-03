import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_item.freezed.dart';

@freezed
abstract class TodoItem with _$TodoItem {
  const factory TodoItem({
    required final String id,
    required final String title,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? description,
    @Default(false) final bool isCompleted,
  }) = _TodoItem;

  const TodoItem._();

  factory TodoItem.create({
    required final String title,
    final String? description,
    final DateTime? now,
  }) {
    final DateTime timestamp = (now ?? DateTime.now()).toUtc();
    return TodoItem(
      id: _TodoIdGenerator.instance.generate(),
      title: title,
      description: description,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }
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
