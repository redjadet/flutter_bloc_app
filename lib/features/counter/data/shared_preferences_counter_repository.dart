import 'dart:async';

import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences-backed implementation of [CounterRepository].
class SharedPreferencesCounterRepository implements CounterRepository {
  SharedPreferencesCounterRepository([final SharedPreferences? instance])
    : _preferencesInstance = instance;

  static const String _preferencesKeyCount = 'last_count';
  static const String _preferencesKeyChanged = 'last_changed';
  static const String _localUserId = 'local';
  static const CounterSnapshot _emptySnapshot = CounterSnapshot(
    userId: _localUserId,
    count: 0,
  );

  final SharedPreferences? _preferencesInstance;
  StreamController<CounterSnapshot>? _watchController;
  CounterSnapshot? _cachedSnapshot;
  Future<void>? _pendingInitialNotification;

  Future<SharedPreferences> _preferences() => _preferencesInstance != null
      ? Future.value(_preferencesInstance)
      : SharedPreferences.getInstance();

  @override
  Future<CounterSnapshot> load() async => _executeSafely<CounterSnapshot>(
    operation: 'load',
    action: (final SharedPreferences preferences) {
      final int count = preferences.getInt(_preferencesKeyCount) ?? 0;
      final int? changedMs = preferences.getInt(_preferencesKeyChanged);
      final DateTime? changed = changedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(changedMs)
          : null;
      final CounterSnapshot snapshot = CounterSnapshot(
        userId: _localUserId,
        count: count,
        lastChanged: changed,
      );
      _cachedSnapshot = snapshot;
      return snapshot;
    },
    fallback: () {
      _cachedSnapshot = _emptySnapshot;
      return _emptySnapshot;
    },
  );

  @override
  Future<void> save(final CounterSnapshot snapshot) async {
    await _executeSafely<void>(
      operation: 'save',
      action: (final SharedPreferences preferences) async {
        final CounterSnapshot normalized = _normalizeSnapshot(snapshot);
        await preferences.setInt(_preferencesKeyCount, normalized.count);
        final DateTime? lastChanged = normalized.lastChanged;
        if (lastChanged != null) {
          await preferences.setInt(
            _preferencesKeyChanged,
            lastChanged.millisecondsSinceEpoch,
          );
        } else {
          await preferences.remove(_preferencesKeyChanged);
        }
        _emitSnapshot(normalized);
      },
    );
  }

  @override
  Stream<CounterSnapshot> watch() {
    _watchController ??= StreamController<CounterSnapshot>.broadcast(
      onListen: _handleOnListen,
      onCancel: _handleOnCancel,
    );
    return _watchController!.stream;
  }

  void _handleOnListen() {
    final CounterSnapshot? cached = _cachedSnapshot;
    if (cached != null) {
      _emitSnapshot(cached);
      return;
    }
    _pendingInitialNotification ??= _loadAndEmitInitial();
    unawaited(_pendingInitialNotification);
  }

  Future<void> _handleOnCancel() async {
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

  Future<void> _loadAndEmitInitial() async {
    try {
      final CounterSnapshot snapshot = await load();
      _emitSnapshot(snapshot);
    } finally {
      _pendingInitialNotification = null;
    }
  }

  CounterSnapshot _normalizeSnapshot(final CounterSnapshot snapshot) {
    if (snapshot.userId == null &&
        snapshot.count == 0 &&
        snapshot.lastChanged == null) {
      return _emptySnapshot;
    }
    return snapshot.userId != null
        ? snapshot
        : snapshot.copyWith(userId: _localUserId);
  }

  void _emitSnapshot(final CounterSnapshot snapshot) {
    _cachedSnapshot = snapshot;
    final StreamController<CounterSnapshot>? controller = _watchController;
    if (controller == null || controller.isClosed) {
      return;
    }
    controller.add(snapshot);
  }

  @visibleForTesting
  Future<void> dispose() async {
    _pendingInitialNotification = null;
    await _watchController?.close();
    _watchController = null;
  }

  Future<T> _executeSafely<T>({
    required final String operation,
    required final FutureOr<T> Function(SharedPreferences preferences) action,
    FutureOr<T> Function()? fallback,
  }) async {
    try {
      final SharedPreferences preferences = await _preferences();
      return await action(preferences);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'SharedPreferencesCounterRepository.$operation failed',
        error,
        stackTrace,
      );
      if (fallback != null) {
        return await fallback();
      }
      throw _SharedPreferencesCounterException(operation, error);
    }
  }
}

class _SharedPreferencesCounterException implements Exception {
  _SharedPreferencesCounterException(this.operation, [this.original]);

  final String operation;
  final Object? original;

  @override
  String toString() =>
      'SharedPreferencesCounterException(operation: $operation, original: $original)';
}
