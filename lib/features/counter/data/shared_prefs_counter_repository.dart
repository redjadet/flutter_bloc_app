import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences-backed implementation of [CounterRepository].
class SharedPreferencesCounterRepository implements CounterRepository {
  SharedPreferencesCounterRepository([SharedPreferences? instance])
    : _prefsInstance = instance;

  static const String _prefsKeyCount = 'last_count';
  static const String _prefsKeyChanged = 'last_changed';
  static const CounterSnapshot _emptySnapshot = CounterSnapshot(count: 0);

  final SharedPreferences? _prefsInstance;

  Future<SharedPreferences> _prefs() => _prefsInstance != null
      ? Future.value(_prefsInstance)
      : SharedPreferences.getInstance();

  @override
  Future<CounterSnapshot> load() async {
    try {
      final SharedPreferences prefs = await _prefs();
      final int count = prefs.getInt(_prefsKeyCount) ?? 0;
      final int? changedMs = prefs.getInt(_prefsKeyChanged);
      final DateTime? changed = changedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(changedMs)
          : null;
      return CounterSnapshot(count: count, lastChanged: changed);
    } catch (e, s) {
      AppLogger.error('SharedPrefsCounterRepository.load failed', e, s);
      return _emptySnapshot;
    }
  }

  @override
  Future<void> save(CounterSnapshot snapshot) async {
    try {
      final SharedPreferences prefs = await _prefs();
      await prefs.setInt(_prefsKeyCount, snapshot.count);
      final DateTime? lastChanged = snapshot.lastChanged;
      if (lastChanged != null) {
        await prefs.setInt(
          _prefsKeyChanged,
          lastChanged.millisecondsSinceEpoch,
        );
      } else {
        // Keep store consistent if timestamp becomes null.
        await prefs.remove(_prefsKeyChanged);
      }
    } catch (e, s) {
      AppLogger.error('SharedPrefsCounterRepository.save failed', e, s);
    }
  }
}
