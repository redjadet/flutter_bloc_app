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

String _generateChangeId() =>
    DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
    Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
