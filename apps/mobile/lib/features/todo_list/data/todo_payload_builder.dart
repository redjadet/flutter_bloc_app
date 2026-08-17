import 'package:flutter_bloc_app/features/todo_list/data/todo_item_dto.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:storage/storage.dart';

/// Builds outbound [SyncOperation] payloads for the todo offline-first repository.
///
/// Single responsibility: map todo save/delete intent to sync operations.
class TodoPayloadBuilder {
  const TodoPayloadBuilder();

  /// Builds a sync operation for saving [item] with [idempotencyKey].
  SyncOperation buildSaveOperation(
    TodoItem item,
    String entityType,
    String idempotencyKey,
  ) => SyncOperation.create(
    entityType: entityType,
    payload: TodoItemDto.fromDomain(item).toMap(),
    idempotencyKey: idempotencyKey,
  );

  /// Builds a sync operation for deleting the todo with [id].
  SyncOperation buildDeleteOperation(
    String id,
    String entityType,
    String idempotencyKey,
  ) => SyncOperation.create(
    entityType: entityType,
    payload: <String, dynamic>{
      'id': id,
      'deleted': true,
    },
    idempotencyKey: idempotencyKey,
  );
}
