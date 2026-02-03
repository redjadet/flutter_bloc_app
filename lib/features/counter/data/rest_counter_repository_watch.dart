part of 'rest_counter_repository.dart';

Stream<CounterSnapshot> _restCounterRepositoryWatch(
  final RestCounterRepository repository,
) {
  final Stream<CounterSnapshot> sourceStream =
      repository._watchController.stream;
  return Stream<CounterSnapshot>.multi((final multi) {
    if (repository._initialLoadHelper.hasResolvedInitialValue) {
      multi.add(repository._latestSnapshot);
    }
    final StreamSubscription<CounterSnapshot> subscription = sourceStream
        .listen(
          multi.add,
          onError: multi.addError,
        );
    multi.onCancel = subscription.cancel;
  });
}

void _emitSnapshot(
  final RestCounterRepository repository,
  final CounterSnapshot snapshot,
) {
  final CounterSnapshot normalized = _storeSnapshot(repository, snapshot);
  if (!repository._watchController.isClosed) {
    repository._watchController.add(normalized);
  }
}

void _triggerInitialLoadIfNeeded(final RestCounterRepository repository) {
  unawaited(
    repository._initialLoadHelper.ensureInitialLoad(
      load: repository.load,
      onValue: (final snapshot) =>
          _emitSnapshot(repository, snapshot),
      onError: (final error, final stackTrace) {
        AppLogger.error(
          'RestCounterRepository.initialLoad failed',
          error,
          stackTrace,
        );
        if (!repository._watchController.isClosed) {
          repository._watchController.addError(error, stackTrace);
        }
      },
    ),
  );
}

Future<void> _handleWatchCancel(final RestCounterRepository repository) async {
  if (repository._watchController.hasListener) {
    return;
  }
  repository
    .._latestSnapshot = RestCounterRepository._emptySnapshot
    .._initialLoadHelper.resetResolution();
}
