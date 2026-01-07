// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TodoItem _$TodoItemFromJson(Map<String, dynamic> json) => _TodoItem(
  id: json['id'] as String,
  title: json['title'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  description: json['description'] as String?,
  isCompleted: json['isCompleted'] as bool? ?? false,
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  priority:
      $enumDecodeNullable(_$TodoPriorityEnumMap, json['priority']) ??
      TodoPriority.none,
  changeId: json['changeId'] as String?,
  lastSyncedAt: json['lastSyncedAt'] == null
      ? null
      : DateTime.parse(json['lastSyncedAt'] as String),
  synchronized: json['synchronized'] as bool? ?? false,
);

Map<String, dynamic> _$TodoItemToJson(_TodoItem instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'description': instance.description,
  'isCompleted': instance.isCompleted,
  'dueDate': instance.dueDate?.toIso8601String(),
  'priority': _$TodoPriorityEnumMap[instance.priority]!,
  'changeId': instance.changeId,
  'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
  'synchronized': instance.synchronized,
};

const _$TodoPriorityEnumMap = {
  TodoPriority.none: 'none',
  TodoPriority.low: 'low',
  TodoPriority.medium: 'medium',
  TodoPriority.high: 'high',
};
