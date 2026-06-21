part of 'offline_first_todo_repository.dart';

bool _shouldMergeRemoteItem({
  required final TodoItem? localItem,
  required final TodoItem remoteItem,
  required final bool Function(TodoItem? localItem, TodoItem remoteItem)
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
  final HiveTodoRepository localRepository,
  final List<TodoItem> remoteItems,
  final String Function() generateChangeId,
  final bool Function(TodoItem? localItem, TodoItem remoteItem)
  shouldApplyRemote,
) async {
  try {
    final List<TodoItem> localItems = await localRepository.fetchAll();
    final Map<String, TodoItem> localMap = {
      for (final TodoItem item in localItems) item.id: item,
    };
    final Set<String> remoteIds = remoteItems
        .map((final item) => item.id)
        .toSet();

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
      final Iterable<TodoItem> freshMatches = freshLocalItems.where(
        (final TodoItem item) => item.id == remoteItem.id,
      );
      final TodoItem? freshLocalItem =
          freshMatches.isEmpty ? null : freshMatches.first;
      if (!_shouldMergeRemoteItem(
        localItem: freshLocalItem,
        remoteItem: remoteItem,
        shouldApplyRemote: shouldApplyRemote,
      )) {
        continue;
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
        await localRepository.delete(localItem.id);
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
  final TodoItem item,
  final TodoRepository? remoteRepository,
  final String Function() generateChangeId,
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

String _generateChangeId() =>
    DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
    Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
