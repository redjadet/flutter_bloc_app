// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class CounterState {
  const CounterState({
    required this.count,
    this.lastChanged,
    this.countdownSeconds = 5,
  });

  final int count;
  final DateTime? lastChanged;
  final int countdownSeconds;

  CounterState copyWith({
    int? count,
    DateTime? lastChanged,
    int? countdownSeconds,
  }) {
    return CounterState(
      count: count ?? this.count,
      lastChanged: lastChanged ?? this.lastChanged,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
    );
  }
}

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(const CounterState(count: 0)) {
    _startTimer();
  }

  static const String _prefsKeyCount = 'last_count';
  static const String _prefsKeyChanged = 'last_changed';
  static const int _autoDecrementInterval = 5; // seconds

  Timer? _timer;
  Timer? _countdownTimer;

  void _startTimer() {
    _timer?.cancel();
    _countdownTimer?.cancel();

    // Start main auto-decrement timer
    _timer = Timer.periodic(Duration(seconds: _autoDecrementInterval), (timer) {
      if (state.count > 0) {
        _autoDecrement();
      }
    });

    // Start countdown timer that updates every second
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    emit(state.copyWith(countdownSeconds: _autoDecrementInterval));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdownSeconds > 0) {
        emit(state.copyWith(countdownSeconds: state.countdownSeconds - 1));
      } else {
        // Reset countdown when it reaches 0
        emit(state.copyWith(countdownSeconds: _autoDecrementInterval));
      }
    });
  }

  void _resetTimer() {
    _startTimer();
  }

  void _autoDecrement() {
    final CounterState next = CounterState(
      count: state.count - 1,
      lastChanged: DateTime.now(),
      countdownSeconds: _autoDecrementInterval,
    );
    emit(next);
    _persist(next);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    return super.close();
  }

  Future<void> loadInitial() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int saved = prefs.getInt(_prefsKeyCount) ?? 0;
    final int? changedMs = prefs.getInt(_prefsKeyChanged);
    final DateTime? changed = changedMs != null
        ? DateTime.fromMillisecondsSinceEpoch(changedMs)
        : null;
    if (saved != state.count || changed != state.lastChanged) {
      emit(
        CounterState(
          count: saved,
          lastChanged: changed,
          countdownSeconds: _autoDecrementInterval,
        ),
      );
    }
  }

  Future<void> _persist(CounterState value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKeyCount, value.count);
    if (value.lastChanged != null) {
      await prefs.setInt(
        _prefsKeyChanged,
        value.lastChanged!.millisecondsSinceEpoch,
      );
    }
  }

  Future<void> increment() async {
    final CounterState next = CounterState(
      count: state.count + 1,
      lastChanged: DateTime.now(),
      countdownSeconds: _autoDecrementInterval,
    );
    emit(next);
    await _persist(next);
    _resetTimer();
  }

  Future<void> decrement() async {
    final CounterState next = CounterState(
      count: state.count - 1,
      lastChanged: DateTime.now(),
      countdownSeconds: _autoDecrementInterval,
    );
    emit(next);
    await _persist(next);
    _resetTimer();
  }
}
