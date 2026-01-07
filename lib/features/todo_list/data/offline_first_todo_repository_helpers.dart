part of 'offline_first_todo_repository.dart';

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
      if (localItem != null &&
          localItem.updatedAt.isAfter(remoteItem.updatedAt)) {
        continue;
      }
      if (localItem != null && !localItem.synchronized) {
        // Preserve local pending changes until they sync.
        if (localItem.changeId == null ||
            localItem.changeId != remoteItem.changeId) {
          continue;
        }
      }
      if (shouldApplyRemote(localItem, remoteItem)) {
        await localRepository.save(
          remoteItem.copyWith(
            changeId: remoteItem.changeId ?? generateChangeId(),
            lastSyncedAt: DateTime.now().toUtc(),
            synchronized: true,
          ),
        );
      }
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

bool _shouldApplyRemote(
  final TodoItem? localItem,
  final TodoItem remoteItem,
) {
  if (localItem == null) {
    return true;
  }
  if (localItem.updatedAt.isAfter(remoteItem.updatedAt)) {
    return false;
  }
  // If local item is synchronized (already synced with Firebase),
  // accept remote changes if timestamp is equal or newer
  // (Firebase console edits don't always update updatedAt, so we accept equal timestamps)
  if (localItem.synchronized) {
    // Accept if remote is equal to or newer than local
    // Use difference to handle equal timestamps (Firebase console edits)
    final Duration difference = remoteItem.updatedAt.difference(
      localItem.updatedAt,
    );
    return !difference.isNegative; // >= 0 means equal or newer
  }
  // If local item has unsynchronized changes, only accept remote if it's definitely newer
  return remoteItem.updatedAt.isAfter(localItem.updatedAt);
}

String _generateChangeId() =>
    DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
    Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
