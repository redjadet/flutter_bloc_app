import 'package:flutter_bloc_app/features/todo_list/data/todo_item_dto.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';

/// Builds outbound [SyncOperation] payloads for the todo offline-first repository.
///
/// Single responsibility: map todo save/delete intent to sync operations.
class TodoPayloadBuilder {
  const TodoPayloadBuilder();

  /// Builds a sync operation for saving [item] with [idempotencyKey].
  SyncOperation buildSaveOperation(
    final TodoItem item,
    final String entityType,
    final String idempotencyKey,
  ) => SyncOperation.create(
    entityType: entityType,
    payload: TodoItemDto.fromDomain(item).toMap(),
    idempotencyKey: idempotencyKey,
  );

  /// Builds a sync operation for deleting the todo with [id].
  SyncOperation buildDeleteOperation(
    final String id,
    final String entityType,
    final String idempotencyKey,
  ) => SyncOperation.create(
    entityType: entityType,
    payload: <String, dynamic>{
      'id': id,
      'deleted': true,
    },
    idempotencyKey: idempotencyKey,
  );
}
