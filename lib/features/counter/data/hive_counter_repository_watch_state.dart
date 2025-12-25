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
    _watchController ??= StreamController<CounterSnapshot>.broadcast();
    return _watchController!.stream;
  }

  void createController({
    required final void Function() onListen,
    required final Future<void> Function() onCancel,
  }) {
    final StreamController<CounterSnapshot>? existing = _watchController;
    if (existing != null) {
      if (!existing.hasListener && !existing.isClosed) {
        unawaited(existing.close());
        _watchController = null;
      } else if (existing.hasListener) {
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
    if (pending != null) {
      try {
        await pending;
      } on Exception {
        // Errors are handled in _performLoadAndEmit.
      }
      if (_pendingInitialNotification != null &&
          _pendingInitialNotification != pending) {
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
      if (cached != null) {
        emitSnapshot(cached);
      } else {
        emitSnapshot(emptySnapshot);
      }
    }
  }

  Future<void> dispose() async {
    _pendingInitialNotification = null;
    await _watchController?.close();
    _watchController = null;
  }
}
