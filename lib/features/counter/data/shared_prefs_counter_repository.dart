import 'package:flutter_bloc_app/features/counter/data/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences-backed implementation of [CounterRepository].
class SharedPreferencesCounterRepository implements CounterRepository {
  static const String _prefsKeyCount = 'last_count';
  static const String _prefsKeyChanged = 'last_changed';

  @override
  Future<CounterSnapshot> load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int count = prefs.getInt(_prefsKeyCount) ?? 0;
      final int? changedMs = prefs.getInt(_prefsKeyChanged);
      final DateTime? changed = changedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(changedMs)
          : null;
      return CounterSnapshot(count: count, lastChanged: changed);
    } catch (e, s) {
      AppLogger.error('SharedPrefsCounterRepository.load failed', e, s);
      return const CounterSnapshot(count: 0);
    }
  }

  @override
  Future<void> save(CounterSnapshot snapshot) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKeyCount, snapshot.count);
      if (snapshot.lastChanged != null) {
        await prefs.setInt(
          _prefsKeyChanged,
          snapshot.lastChanged!.millisecondsSinceEpoch,
        );
      }
    } catch (e, s) {
      AppLogger.error('SharedPrefsCounterRepository.save failed', e, s);
    }
  }
}
