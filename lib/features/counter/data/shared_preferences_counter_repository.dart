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
  static const CounterSnapshot _emptySnapshot = CounterSnapshot(count: 0);

  final SharedPreferences? _preferencesInstance;

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
      return CounterSnapshot(count: count, lastChanged: changed);
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
    } catch (e, s) {
      AppLogger.error('SharedPreferencesCounterRepository.save failed', e, s);
    }
  }
}
