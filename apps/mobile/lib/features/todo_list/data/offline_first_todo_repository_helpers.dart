part of 'offline_first_todo_repository.dart';

bool _shouldMergeRemoteItem({
  required TodoItem? localItem,
  required TodoItem remoteItem,
  required bool Function(TodoItem? localItem, TodoItem remoteItem)
  shouldApplyRemote,
}) {
  if (localItem != null && localItem.updatedAt.isAfter(remoteItem.updatedAt)) {
    return false;
  }
  if (localItem != null && !localItem.synchronized) {
    // Preserve local pending changes until they sync.
    if (localItem.changeId == null ||
        localItem.changeId != remoteItem.changeId) {
      return false;
    }
  }
  return shouldApplyRemote(localItem, remoteItem);
}

Future<void> _mergeRemoteIntoLocal(
  HiveTodoRepository localRepository,
  List<TodoItem> remoteItems,
  String Function() generateChangeId,
  bool Function(TodoItem? localItem, TodoItem remoteItem) shouldApplyRemote, {
  bool Function()? shouldAbortMerge,
}) async {
  try {
    if (shouldAbortMerge?.call() ?? false) {
      return;
    }
    final List<TodoItem> localItems = await localRepository.fetchAll();
    if (shouldAbortMerge?.call() ?? false) {
      return;
    }
    final Map<String, TodoItem> localMap = {
      for (final TodoItem item in localItems) item.id: item,
    };
    final Set<String> remoteIds = remoteItems.map((item) => item.id).toSet();

    // Merge remote items into local, applying conflict resolution
    for (final TodoItem remoteItem in remoteItems) {
      final TodoItem? localItem = localMap[remoteItem.id];
      if (!_shouldMergeRemoteItem(
        localItem: localItem,
        remoteItem: remoteItem,
        shouldApplyRemote: shouldApplyRemote,
      )) {
        continue;
      }

      // Re-read before save so a local write during the initial fetch cannot be
      // overwritten by a stale remote decision (TOCTOU).
      final List<TodoItem> freshLocalItems = await localRepository.fetchAll();
      if (shouldAbortMerge?.call() ?? false) {
        return;
      }
      final Iterable<TodoItem> freshMatches = freshLocalItems.where(
        (item) => item.id == remoteItem.id,
      );
      final TodoItem? freshLocalItem = freshMatches.isEmpty
          ? null
          : freshMatches.first;
      if (!_shouldMergeRemoteItem(
        localItem: freshLocalItem,
        remoteItem: remoteItem,
        shouldApplyRemote: shouldApplyRemote,
      )) {
        continue;
      }

      if (shouldAbortMerge?.call() ?? false) {
        return;
      }
      await localRepository.save(
        remoteItem.copyWith(
          changeId: remoteItem.changeId ?? generateChangeId(),
          lastSyncedAt: DateTime.now().toUtc(),
          synchronized: true,
        ),
      );
    }

    for (final TodoItem localItem in localItems) {
      if (!remoteIds.contains(localItem.id) && localItem.synchronized) {
        // Re-read before delete for the same reason as remote saves: a local
        // edit may have made this item pending after the initial snapshot.
        final List<TodoItem> freshLocalItems = await localRepository.fetchAll();
        if (shouldAbortMerge?.call() ?? false) {
          return;
        }
        final Iterable<TodoItem> freshMatches = freshLocalItems.where(
          (item) => item.id == localItem.id,
        );
        final TodoItem? freshLocalItem = freshMatches.isEmpty
            ? null
            : freshMatches.first;
        if (freshLocalItem != null && freshLocalItem.synchronized) {
          if (shouldAbortMerge?.call() ?? false) {
            return;
          }
          await localRepository.delete(localItem.id);
        }
      }
    }
  } on Exception catch (error, stackTrace) {
    AppLogger.error(
      'OfflineFirstTodoRepository._mergeRemoteIntoLocal failed',
      error,
      stackTrace,
    );
  }
}

TodoItem _normalizeItem(
  TodoItem item,
  TodoDataSource? remoteRepository,
  String Function() generateChangeId,
) {
  final DateTime now = DateTime.now().toUtc();
  final String changeId = item.changeId ?? generateChangeId();
  return item.copyWith(
    updatedAt: item.updatedAt.isBefore(now) ? now : item.updatedAt,
    changeId: changeId,
    synchronized: remoteRepository == null,
    lastSyncedAt: remoteRepository == null ? now : item.lastSyncedAt,
  );
}

String _generateChangeId() => generateOfflineChangeId();
