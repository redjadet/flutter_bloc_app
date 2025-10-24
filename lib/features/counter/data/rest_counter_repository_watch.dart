part of 'rest_counter_repository.dart';

Stream<CounterSnapshot> _restCounterRepositoryWatch(
  final RestCounterRepository repository,
) {
  repository._watchController ??= StreamController<CounterSnapshot>.broadcast(
    onListen: () => _triggerInitialLoadIfNeeded(repository),
    onCancel: () => _handleWatchCancel(repository),
  );

  final Stream<CounterSnapshot> sourceStream =
      repository._watchController!.stream;
  return Stream<CounterSnapshot>.multi((final multi) {
    if (repository._hasResolvedInitialValue) {
      multi.add(repository._latestSnapshot);
    }
    final StreamSubscription<CounterSnapshot> subscription = sourceStream
        .listen(multi.add, onError: multi.addError);
    multi.onCancel = subscription.cancel;
  });
}

Future<void> _restCounterRepositoryDispose(
  final RestCounterRepository repository,
) async {
  if (repository._ownsClient) {
    repository._client.close();
  }
  unawaited(repository._watchController?.close());
  repository._watchController = null;
}

void _emitSnapshot(
  final RestCounterRepository repository,
  final CounterSnapshot snapshot,
) {
  final CounterSnapshot normalized = _storeSnapshot(repository, snapshot);
  final StreamController<CounterSnapshot>? controller =
      repository._watchController;
  if (controller != null && !controller.isClosed) {
    controller.add(normalized);
  }
}

void _triggerInitialLoadIfNeeded(final RestCounterRepository repository) {
  if (repository._watchController == null) {
    return;
  }
  if (repository._initialLoadCompleter != null) {
    return;
  }
  final Completer<void> completer = Completer<void>();
  repository._initialLoadCompleter = completer;
  _startInitialLoad(repository, completer);
}

void _startInitialLoad(
  final RestCounterRepository repository,
  final Completer<void> completer,
) {
  Future<void> run() async {
    try {
      final CounterSnapshot snapshot = await repository.load();
      _emitSnapshot(repository, snapshot);
    } on CounterError catch (error, stackTrace) {
      AppLogger.error(
        'RestCounterRepository.initialLoad failed',
        error,
        stackTrace,
      );
      repository._watchController?.addError(error, stackTrace);
    } finally {
      completer.complete();
      repository._initialLoadCompleter = null;
    }
  }

  unawaited(run());
}

Future<void> _handleWatchCancel(final RestCounterRepository repository) async {
  final StreamController<CounterSnapshot>? controller =
      repository._watchController;
  if (controller == null) {
    return;
  }
  if (controller.hasListener) {
    return;
  }
  repository._watchController = null;
  await controller.close();
}
