// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:flutter_bloc_app/domain/domain.dart';
import 'package:flutter_bloc_app/data/data.dart';
import 'package:flutter_bloc_app/presentation/counter_state.dart';

export 'package:flutter_bloc_app/presentation/counter_state.dart';

class CounterCubit extends Cubit<CounterState> {
  CounterCubit({CounterRepository? repository})
      : _repository = repository ?? SharedPrefsCounterRepository(),
        super(const CounterState(count: 0)) {
    _startTimer();
  }

  static const int _autoDecrementIntervalSeconds = 5;

  final CounterRepository _repository;

  Timer? _autoDecrementTimer;
  Timer? _countdownTimer;

  void _startTimer() {
    _autoDecrementTimer?.cancel();
    _countdownTimer?.cancel();

    _autoDecrementTimer =
        Timer.periodic(const Duration(seconds: _autoDecrementIntervalSeconds), (_) {
      if (state.count > 0) {
        _autoDecrement();
      }
    });

    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    emit(state.copyWith(countdownSeconds: _autoDecrementIntervalSeconds));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.countdownSeconds > 0) {
        emit(state.copyWith(countdownSeconds: state.countdownSeconds - 1));
      } else {
        emit(state.copyWith(countdownSeconds: _autoDecrementIntervalSeconds));
      }
    });
  }

  void _resetTimer() {
    _startTimer();
  }

  Future<void> loadInitial() async {
    final CounterSnapshot snapshot = await _repository.load();
    if (snapshot.count != state.count || snapshot.lastChanged != state.lastChanged) {
      emit(CounterState(
        count: snapshot.count,
        lastChanged: snapshot.lastChanged,
        countdownSeconds: _autoDecrementIntervalSeconds,
      ));
    }
  }

  Future<void> _persistCurrent() async {
    await _repository.save(
      CounterSnapshot(count: state.count, lastChanged: state.lastChanged),
    );
  }

  void _autoDecrement() {
    final CounterState next = CounterState(
      count: state.count - 1,
      lastChanged: DateTime.now(),
      countdownSeconds: _autoDecrementIntervalSeconds,
    );
    emit(next);
    _persistCurrent();
  }

  @override
  Future<void> close() {
    _autoDecrementTimer?.cancel();
    _countdownTimer?.cancel();
    return super.close();
  }

  Future<void> increment() async {
    final CounterState next = CounterState(
      count: state.count + 1,
      lastChanged: DateTime.now(),
      countdownSeconds: _autoDecrementIntervalSeconds,
    );
    emit(next);
    await _persistCurrent();
    _resetTimer();
  }

  Future<void> decrement() async {
    final CounterState next = CounterState(
      count: state.count - 1,
      lastChanged: DateTime.now(),
      countdownSeconds: _autoDecrementIntervalSeconds,
    );
    emit(next);
    await _persistCurrent();
    _resetTimer();
  }
}
