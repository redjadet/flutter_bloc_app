part of 'offline_first_todo_repository.dart';

class OfflineFirstTodoRepository implements TodoRepository, SyncableRepository {
  OfflineFirstTodoRepository({
    required this._localRepository,
    required this._pendingSyncRepository,
    required this._registry,
    required this._timerService,
    this._remoteRepository,
    final TodoMergePolicy? mergePolicy,
    final TodoPayloadBuilder? payloadBuilder,
  }) : _mergePolicy = mergePolicy ?? const TodoMergePolicy(),
       _payloadBuilder = payloadBuilder ?? const TodoPayloadBuilder() {
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
  final TimerService _timerService;
  final TodoMergePolicy _mergePolicy;
  final TodoPayloadBuilder _payloadBuilder;

  final SubscriptionManager _subscriptionManager = SubscriptionManager();
  final TimerHandleManager _timerHandles = TimerHandleManager();
  bool _remoteRestartScheduled = false;
  TimerDisposable? _remoteRestartHandle;

  @visibleForTesting
  bool get hasRemoteRepository => _remoteRepository != null;

  @override
  String get entityType => todoEntity;

  @override
  Future<int> pendingSyncOperationCount({DateTime? now}) async {
    final List<SyncOperation> pending = await _pendingSyncRepository
        .getPendingOperations(
          now: now ?? DateTime.now().toUtc(),
        );
    return pending.where((final op) => op.entityType == todoEntity).length;
  }

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
    if (_subscriptionManager.isDisposed) {
      return;
    }
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
            _mergePolicy.shouldApplyRemote,
          ),
        );
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'OfflineFirstTodoRepository._startRemoteWatch failed',
          error,
          stackTrace,
        );
        final StreamSubscription<List<TodoItem>>? currentSubscription =
            _remoteWatchSubscription;
        _remoteWatchSubscription = null;
        unawaited(_subscriptionManager.cancelRegistered(currentSubscription));
        _scheduleRemoteRestart();
      },
      onDone: () {
        final StreamSubscription<List<TodoItem>>? currentSubscription =
            _remoteWatchSubscription;
        _remoteWatchSubscription = null;
        unawaited(_subscriptionManager.cancelRegistered(currentSubscription));
        _scheduleRemoteRestart();
      },
      cancelOnError: true,
    );
    _subscriptionManager.register(_remoteWatchSubscription);
  }

  void _scheduleRemoteRestart() {
    if (_subscriptionManager.isDisposed || _remoteRestartScheduled) {
      return;
    }
    _remoteRestartScheduled = true;
    _remoteRestartHandle?.dispose();
    _timerHandles.unregister(_remoteRestartHandle);
    late final TimerDisposable handle;
    handle = _timerService.runOnce(const Duration(seconds: 2), () {
      _timerHandles.unregister(handle);
      if (identical(_remoteRestartHandle, handle)) {
        _remoteRestartHandle = null;
      }
      _remoteRestartScheduled = false;
      if (_subscriptionManager.isDisposed) {
        return;
      }
      _startRemoteWatch();
    });
    _remoteRestartHandle = handle;
    _timerHandles.register(handle);
  }

  @override
  Future<void> save(final TodoItem item) async {
    final TodoItem normalized = _normalizeItem(
      item,
      _remoteRepository,
      _generateChangeId,
    );
    await _localRepository.save(normalized);
    if (!hasRemoteRepository) {
      return;
    }
    await _syncSaveToRemote(normalized);
  }

  @override
  Future<void> delete(final String id) async {
    final String normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      return;
    }
    await _localRepository.delete(normalizedId);
    if (!hasRemoteRepository) {
      return;
    }
    await _syncDeleteToRemote(normalizedId);
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
    if (_isDeleteOperation(operation)) {
      await _processDeleteOperation(operation);
      return;
    }
    final TodoItem? item = _parseOperationItem(operation);
    if (item == null) {
      return;
    }
    await _processSaveOperation(item);
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
        _mergePolicy.shouldApplyRemote,
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'OfflineFirstTodoRepository.pullRemote failed',
        error,
        stackTrace,
      );
    }
  }

  bool _isDeleteOperation(final SyncOperation operation) =>
      operation.payload.containsKey('deleted') &&
      operation.payload['deleted'] == true;

  Future<void> _syncSaveToRemote(final TodoItem normalized) async {
    final TodoRepository? remoteRepository = _remoteRepository;
    if (remoteRepository == null) {
      return;
    }
    final String changeId = normalized.changeId ?? _generateChangeId();

    try {
      await remoteRepository.save(normalized);
      await _markLocalItemSynchronized(normalized);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        IntegrationLogMessages.offlineFirstTodoSaveSyncFailed,
        error,
        stackTrace,
      );
      final SyncOperation operation = _payloadBuilder.buildSaveOperation(
        normalized,
        entityType,
        changeId,
      );
      await _pendingSyncRepository.enqueue(operation);
    }
  }

  Future<void> _syncDeleteToRemote(final String normalizedId) async {
    final TodoRepository? remoteRepository = _remoteRepository;
    if (remoteRepository == null) {
      return;
    }

    try {
      await remoteRepository.delete(normalizedId);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        IntegrationLogMessages.offlineFirstTodoDeleteSyncFailed,
        error,
        stackTrace,
      );
      final String changeId = _generateChangeId();
      final SyncOperation operation = _payloadBuilder.buildDeleteOperation(
        normalizedId,
        entityType,
        '$normalizedId-$changeId',
      );
      await _pendingSyncRepository.enqueue(operation);
    }
  }

  Future<void> _processDeleteOperation(final SyncOperation operation) async {
    final String? deleteId = _extractDeleteId(operation);
    if (deleteId == null) {
      return;
    }

    final TodoRepository? remoteRepository = _remoteRepository;
    if (remoteRepository != null) {
      await remoteRepository.delete(deleteId);
    }
    await _localRepository.delete(deleteId);
  }

  Future<void> _processSaveOperation(final TodoItem item) async {
    if (_remoteRepository case final TodoRepository remoteRepository?) {
      final Iterable<TodoItem> remoteMatches =
          (await remoteRepository.fetchAll()).where(
            (final candidate) => candidate.id == item.id,
          );
      final TodoItem? remoteItem = remoteMatches.isEmpty
          ? null
          : remoteMatches.first;
      if (remoteItem != null &&
          !_mergePolicy.shouldPushPendingToRemote(item, remoteItem)) {
        final Iterable<TodoItem> localMatches =
            (await _localRepository.fetchAll()).where(
              (final candidate) => candidate.id == item.id,
            );
        final TodoItem? localItem = localMatches.isEmpty
            ? null
            : localMatches.first;
        if (_mergePolicy.shouldApplyRemote(localItem, remoteItem)) {
          await _localRepository.save(
            remoteItem.copyWith(
              changeId: remoteItem.changeId ?? _generateChangeId(),
              lastSyncedAt: DateTime.now().toUtc(),
              synchronized: true,
            ),
          );
        }
        return;
      }
      await remoteRepository.save(item);
    }
    await _markLocalItemSynchronized(item);
  }

  String? _extractDeleteId(final SyncOperation operation) {
    final dynamic idRaw = operation.payload['id'];
    if (idRaw is! String) {
      return null;
    }
    final String normalizedId = idRaw.trim();
    return normalizedId.isEmpty ? null : normalizedId;
  }

  TodoItem? _parseOperationItem(final SyncOperation operation) {
    try {
      return TodoItemDto.fromMap(operation.payload).toDomain();
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'OfflineFirstTodoRepository.processOperation: malformed payload',
        error,
        stackTrace,
      );
      // Malformed payloads are not recoverable via retries, so skip safely.
      return null;
    }
  }

  Future<void> _markLocalItemSynchronized(final TodoItem item) {
    return _localRepository.save(
      item.copyWith(
        synchronized: true,
        lastSyncedAt: DateTime.now().toUtc(),
      ),
    );
  }

  /// Cancels the remote watch subscription.
  ///
  /// Call when the repository is disposed (e.g. on logout/reset).
  Future<void> dispose() async {
    _remoteWatchSubscription = null;
    _remoteRestartScheduled = false;
    _remoteRestartHandle?.dispose();
    _timerHandles.unregister(_remoteRestartHandle);
    _remoteRestartHandle = null;
    await _timerHandles.dispose();
    await _subscriptionManager.dispose();
    final SyncableRepository? registeredRepository = _registry.resolve(
      entityType,
    );
    if (identical(registeredRepository, this)) {
      _registry.unregister(entityType);
    }
  }
}
