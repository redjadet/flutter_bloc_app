import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';

/// Decides whether a remote todo item should be applied over local state.
///
/// Used by offline-first todo repository to avoid overwriting newer or
/// unsynced local changes when merging remote data.
class TodoMergePolicy {
  const TodoMergePolicy();

  /// Returns true if [remoteItem] should be written to local storage.
  ///
  /// When local is synchronized, accepts remote if equal or newer; when local
  /// has unsynced changes, accepts only if remote is strictly newer.
  bool shouldApplyRemote(
    final TodoItem? localItem,
    final TodoItem remoteItem,
  ) {
    if (localItem == null) {
      return true;
    }
    if (localItem.updatedAt.isAfter(remoteItem.updatedAt)) {
      return false;
    }
    if (localItem.synchronized) {
      final Duration difference = remoteItem.updatedAt.difference(
        localItem.updatedAt,
      );
      return !difference.isNegative;
    }
    return remoteItem.updatedAt.isAfter(localItem.updatedAt);
  }
}
