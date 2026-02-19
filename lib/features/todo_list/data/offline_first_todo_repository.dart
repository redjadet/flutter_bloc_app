import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc_app/features/todo_list/data/hive_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

part 'offline_first_todo_repository_helpers.dart';

class OfflineFirstTodoRepository implements TodoRepository, SyncableRepository {
  OfflineFirstTodoRepository({
    required final HiveTodoRepository localRepository,
    required final PendingSyncRepository pendingSyncRepository,
    required final SyncableRepositoryRegistry registry,
    final TodoRepository? remoteRepository,
  }) : _localRepository = localRepository,
       _remoteRepository = remoteRepository,
       _pendingSyncRepository = pendingSyncRepository,
       _registry = registry {
    _registry.register(this);
    if (_remoteRepository != null) {
      _startRemoteWatch();
    }
  }

  static const String todoEntity = 'todo';

  final HiveTodoRepository _localRepository;
  final TodoRepository? _remoteRepository;
  final PendingSyncRepository _pendingSyncRepository;
  final SyncableRepositoryRegistry _registry;

  @override
  String get entityType => todoEntity;

  @override
  Future<List<TodoItem>> fetchAll() => _localRepository.fetchAll();

  // ignore: cancel_subscriptions - Subscription is managed per watchAll() call lifecycle
  StreamSubscription<List<TodoItem>>? _remoteWatchSubscription;

  @override
  Stream<List<TodoItem>> watchAll() {
    // Start listening to remote changes if remote repository exists
    _startRemoteWatch();
    // Return local stream - it will emit when local data changes
    // (including when we merge remote changes into local)
    return _localRepository.watchAll();
  }

  void _startRemoteWatch() {
    // Only watch remote if we have a remote repository and aren't already watching
    final TodoRepository? remoteRepo = _remoteRepository;
    if (remoteRepo == null || _remoteWatchSubscription != null) {
      return;
    }

    _remoteWatchSubscription = remoteRepo.watchAll().listen(
      (final remoteItems) {
        // Merge remote changes into local storage
        // This will trigger the local watch stream to emit
        unawaited(
          _mergeRemoteIntoLocal(
            _localRepository,
            remoteItems,
            _generateChangeId,
            _shouldApplyRemote,
          ),
        );
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'OfflineFirstTodoRepository._startRemoteWatch failed',
          error,
          stackTrace,
        );
        _remoteWatchSubscription = null;
        unawaited(_restartRemoteWatch());
      },
      onDone: () {
        _remoteWatchSubscription = null;
        unawaited(_restartRemoteWatch());
      },
    );
  }

  Future<void> _restartRemoteWatch() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    _startRemoteWatch();
  }

  @override
  Future<void> save(final TodoItem item) async {
    final TodoItem normalized = _normalizeItem(
      item,
      _remoteRepository,
      _generateChangeId,
    );
    await _localRepository.save(normalized);
    if (_remoteRepository == null) {
      return;
    }
    final String changeId = normalized.changeId ?? _generateChangeId();
    // Try to save to remote immediately
    try {
      await _remoteRepository.save(normalized);
      // Update local with sync status after successful remote save
      await _localRepository.save(
        normalized.copyWith(
          synchronized: true,
          lastSyncedAt: DateTime.now().toUtc(),
        ),
      );
    } on Exception catch (error, stackTrace) {
      // If immediate sync fails, queue for later retry
      AppLogger.error(
        'OfflineFirstTodoRepository.save immediate sync failed, queuing for retry',
        error,
        stackTrace,
      );
      final SyncOperation operation = SyncOperation.create(
        entityType: entityType,
        payload: normalized.toJson(),
        idempotencyKey: changeId,
      );
      await _pendingSyncRepository.enqueue(operation);
    }
  }

  @override
  Future<void> delete(final String id) async {
    await _localRepository.delete(id);
    if (_remoteRepository == null) {
      return;
    }
    // Try to delete from remote immediately
    try {
      await _remoteRepository.delete(id);
    } on Exception catch (error, stackTrace) {
      // If immediate sync fails, queue for later retry
      AppLogger.error(
        'OfflineFirstTodoRepository.delete immediate sync failed, queuing for retry',
        error,
        stackTrace,
      );
      final String changeId = _generateChangeId();
      final SyncOperation operation = SyncOperation.create(
        entityType: entityType,
        payload: <String, dynamic>{
          'id': id,
          'deleted': true,
        },
        idempotencyKey: '$id-$changeId',
      );
      await _pendingSyncRepository.enqueue(operation);
    }
  }

  @override
  Future<void> clearCompleted() async {
    final List<TodoItem> items = await _localRepository.fetchAll();
    final List<TodoItem> completedItems = items
        .where((final item) => item.isCompleted)
        .toList(growable: false);
    for (final TodoItem item in completedItems) {
      await delete(item.id);
    }
  }

  @override
  Future<void> processOperation(final SyncOperation operation) async {
    if (operation.payload.containsKey('deleted') &&
        operation.payload['deleted'] == true) {
      // Handle delete operation
      final String? id = operation.payload['id'] as String?;
      if (id == null) {
        return;
      }
      if (_remoteRepository != null) {
        await _remoteRepository.delete(id);
      }
      await _localRepository.delete(id);
      return;
    }
    // Handle save operation
    final TodoItem item = TodoItem.fromJson(operation.payload);
    if (_remoteRepository == null) {
      await _localRepository.save(
        item.copyWith(
          synchronized: true,
          lastSyncedAt: DateTime.now().toUtc(),
        ),
      );
      return;
    }
    await _remoteRepository.save(item);
    await _localRepository.save(
      item.copyWith(
        synchronized: true,
        lastSyncedAt: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Future<void> pullRemote() async {
    if (_remoteRepository == null) {
      return;
    }
    try {
      final List<TodoItem> remoteItems = await _remoteRepository.fetchAll();
      await _mergeRemoteIntoLocal(
        _localRepository,
        remoteItems,
        _generateChangeId,
        _shouldApplyRemote,
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'OfflineFirstTodoRepository.pullRemote failed',
        error,
        stackTrace,
      );
    }
  }

  /// Cancels the remote watch subscription.
  ///
  /// Call when the repository is disposed (e.g. on logout/reset).
  Future<void> dispose() async {
    final sub = _remoteWatchSubscription;
    _remoteWatchSubscription = null;
    await sub?.cancel();
    final SyncableRepository? registeredRepository = _registry.resolve(
      entityType,
    );
    if (identical(registeredRepository, this)) {
      _registry.unregister(entityType);
    }
  }
}
