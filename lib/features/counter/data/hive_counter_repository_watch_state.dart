import 'dart:async';

import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class HiveCounterRepositoryWatchState {
  HiveCounterRepositoryWatchState({
    required this.loadSnapshot,
    required this.emptySnapshot,
  });

  final Future<CounterSnapshot> Function() loadSnapshot;
  final CounterSnapshot emptySnapshot;

  StreamController<CounterSnapshot>? _watchController;
  CounterSnapshot? _cachedSnapshot;
  Future<void>? _pendingInitialNotification;

  CounterSnapshot? get cachedSnapshot => _cachedSnapshot;

  set cachedSnapshot(final CounterSnapshot snapshot) =>
      _cachedSnapshot = snapshot;

  Stream<CounterSnapshot> get stream {
    final controller = _watchController ??=
        StreamController<CounterSnapshot>.broadcast();
    return controller.stream;
  }

  void createController({
    required final void Function() onListen,
    required final Future<void> Function() onCancel,
  }) {
    final StreamController<CounterSnapshot>? existing = _watchController;
    if (existing case final controller?) {
      if (!controller.hasListener && !controller.isClosed) {
        unawaited(controller.close());
        _watchController = null;
      } else if (controller.hasListener) {
        return;
      }
    }
    _watchController ??= StreamController<CounterSnapshot>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
    );
  }

  Future<void> closeIfNoListeners() async {
    final StreamController<CounterSnapshot>? controller = _watchController;
    if (controller == null) {
      return;
    }
    if (!controller.hasListener) {
      _watchController = null;
      _pendingInitialNotification = null;
      await controller.close();
    }
  }

  void emitSnapshot(final CounterSnapshot snapshot) {
    _cachedSnapshot = snapshot;
    final StreamController<CounterSnapshot>? controller = _watchController;
    if (controller == null || controller.isClosed) {
      return;
    }
    controller.add(snapshot);
  }

  Future<void> loadAndEmitInitial() async {
    final Future<void>? pending = _pendingInitialNotification;
    if (pending case final existingPending?) {
      try {
        await existingPending;
      } on Exception {
        // Errors are handled in _performLoadAndEmit.
      }
      if (_pendingInitialNotification != null &&
          _pendingInitialNotification != existingPending) {
        return;
      }
    }

    final Future<void> currentLoad = _performLoadAndEmit();
    _pendingInitialNotification = currentLoad;
    try {
      await currentLoad;
    } finally {
      if (_pendingInitialNotification == currentLoad) {
        _pendingInitialNotification = null;
      }
    }
  }

  Future<void> _performLoadAndEmit() async {
    try {
      final CounterSnapshot snapshot = await loadSnapshot();
      emitSnapshot(snapshot);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'Failed to load and emit initial snapshot',
        error,
        stackTrace,
      );
      final CounterSnapshot? cached = _cachedSnapshot;
      if (cached case final snapshot?) {
        emitSnapshot(snapshot);
        return;
      }
      emitSnapshot(emptySnapshot);
    }
  }

  Future<void> dispose() async {
    _pendingInitialNotification = null;
    await _watchController?.close();
    _watchController = null;
  }
}
