import 'dart:async';

import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences-backed implementation of [CounterRepository].
class SharedPreferencesCounterRepository implements CounterRepository {
  SharedPreferencesCounterRepository([SharedPreferences? instance])
    : _preferencesInstance = instance;

  static const String _preferencesKeyCount = 'last_count';
  static const String _preferencesKeyChanged = 'last_changed';
  static const CounterSnapshot _emptySnapshot = CounterSnapshot(
    userId: 'local',
    count: 0,
  );

  final SharedPreferences? _preferencesInstance;
  StreamController<CounterSnapshot>? _watchController;

  Future<SharedPreferences> _preferences() => _preferencesInstance != null
      ? Future.value(_preferencesInstance)
      : SharedPreferences.getInstance();

  @override
  Future<CounterSnapshot> load() async {
    try {
      final SharedPreferences preferences = await _preferences();
      final int count = preferences.getInt(_preferencesKeyCount) ?? 0;
      final int? changedMs = preferences.getInt(_preferencesKeyChanged);
      final DateTime? changed = changedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(changedMs)
          : null;
      return CounterSnapshot(
        userId: 'local',
        count: count,
        lastChanged: changed,
      );
    } catch (e, s) {
      AppLogger.error('SharedPreferencesCounterRepository.load failed', e, s);
      return _emptySnapshot;
    }
  }

  @override
  Future<void> save(CounterSnapshot snapshot) async {
    try {
      final SharedPreferences preferences = await _preferences();
      await preferences.setInt(_preferencesKeyCount, snapshot.count);
      final DateTime? lastChanged = snapshot.lastChanged;
      if (lastChanged != null) {
        await preferences.setInt(
          _preferencesKeyChanged,
          lastChanged.millisecondsSinceEpoch,
        );
      } else {
        // Keep store consistent if timestamp becomes null.
        await preferences.remove(_preferencesKeyChanged);
      }
      _watchController?.add(
        snapshot.userId != null ? snapshot : snapshot.copyWith(userId: 'local'),
      );
    } catch (e, s) {
      AppLogger.error('SharedPreferencesCounterRepository.save failed', e, s);
    }
  }

  @override
  Stream<CounterSnapshot> watch() {
    _watchController ??= StreamController<CounterSnapshot>.broadcast(
      onListen: () async {
        _watchController?.add(await load());
      },
    );
    return _watchController!.stream;
  }
}
