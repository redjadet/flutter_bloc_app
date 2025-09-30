import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/counter/data/shared_preferences_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

import 'test_helpers.dart';

void main() {
  group('CounterCubit', () {
    setUp(() async {
      setupSharedPreferencesMock();
    });

    CounterCubit createCubit({
      CounterRepository? repository,
      TimerService? timerService,
      bool startTicker = true,
      Duration loadDelay = Duration.zero,
    }) {
      final CounterCubit cubit = CounterCubit(
        repository: repository ?? MockCounterRepository(),
        timerService: timerService,
        startTicker: startTicker,
        loadDelay: loadDelay,
      );
      addTearDown(cubit.close);
      return cubit;
    }

    test('initial state is count 0 with countdown 5', () {
      final CounterCubit cubit = createCubit(
        repository: SharedPreferencesCounterRepository(),
      );
      expect(cubit.state.count, 0);
      expect(cubit.state.lastChanged, isNull);
      expect(cubit.state.countdownSeconds, 5);
    });

    blocTest<CounterCubit, CounterState>(
      'emits state with count 1 and lastChanged set on increment',
      build: () => CounterCubit(repository: MockCounterRepository()),
      act: (cubit) => cubit.increment(),
      expect: () => [
        isA<CounterState>()
            .having((s) => s.count, 'count', 1)
            .having(
              (s) => s.lastChanged is DateTime,
              'lastChanged is DateTime',
              true,
            )
            .having((s) => s.countdownSeconds, 'countdownSeconds', 5),
      ],
      skip: 0,
    );

    blocTest<CounterCubit, CounterState>(
      'does not go below 0 and emits error on decrement at 0',
      build: () => CounterCubit(repository: MockCounterRepository()),
      act: (cubit) => cubit.decrement(),
      expect: () => [
        isA<CounterState>()
            .having((s) => s.count, 'count', 0)
            .having(
              (s) => s.error?.type.name,
              'errorMessage',
              'cannotGoBelowZero',
            ),
      ],
      skip: 0,
    );

    test(
      'clearError clears existing error and resets status to idle',
      () async {
        final CounterCubit cubit = createCubit();
        cubit.emit(
          cubit.state.copyWith(
            error: const CounterError.cannotGoBelowZero(),
            status: CounterStatus.error,
          ),
        );

        cubit.clearError();

        expect(cubit.state.error, isNull);
        expect(cubit.state.status, CounterStatus.idle);
      },
    );

    test('clearError is a no-op when no error is present', () async {
      final CounterCubit cubit = createCubit();
      final CounterState initial = cubit.state;

      cubit.clearError();

      expect(cubit.state, same(initial));
    });

    test('loadInitial loads saved value with countdown 5', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{'last_count': 7});
      final CounterCubit cubit = createCubit(
        repository: SharedPreferencesCounterRepository(),
      );
      await cubit.loadInitial();
      expect(cubit.state.count, 7);
      expect(cubit.state.lastChanged, isNull);
      expect(cubit.state.countdownSeconds, 5);
    });

    test('loadInitial keeps remote value without catch-up', () async {
      final DateTime fixedNow = DateTime(2024, 1, 1, 12, 0, 0);
      final DateTime lastChanged = fixedNow.subtract(
        const Duration(seconds: 12),
      );
      final recordingRepo = _RecordingCounterRepository(
        CounterSnapshot(count: 5, lastChanged: lastChanged),
      );
      final CounterCubit cubit = CounterCubit(
        repository: recordingRepo,
        timerService: FakeTimerService(),
        startTicker: false,
        now: () => fixedNow,
      );
      addTearDown(cubit.close);

      await cubit.loadInitial();

      expect(cubit.state.count, 5);
      expect(cubit.state.countdownSeconds, 5);
      expect(cubit.state.lastChanged, lastChanged);
      expect(recordingRepo.saved, isNull);
    });

    test('loadInitial preserves zero state without forcing catch-up', () async {
      final DateTime fixedNow = DateTime(2024, 1, 1, 12, 0, 0);
      final DateTime lastChanged = fixedNow.subtract(
        const Duration(seconds: 20),
      );
      final recordingRepo = _RecordingCounterRepository(
        CounterSnapshot(count: 0, lastChanged: lastChanged),
      );
      final CounterCubit cubit = CounterCubit(
        repository: recordingRepo,
        timerService: FakeTimerService(),
        startTicker: false,
        now: () => fixedNow,
      );
      addTearDown(cubit.close);

      await cubit.loadInitial();

      expect(cubit.state.count, 0);
      expect(cubit.state.countdownSeconds, 5);
      expect(cubit.state.isAutoDecrementActive, isFalse);
      expect(cubit.state.lastChanged, lastChanged);
      expect(recordingRepo.saved, isNull);
    });

    test('loadInitial with mock repository loads correctly', () async {
      final mockRepo = MockCounterRepository(
        snapshot: const CounterSnapshot(count: 42, lastChanged: null),
      );
      final CounterCubit cubit = createCubit(repository: mockRepo);
      await cubit.loadInitial();
      expect(cubit.state.count, 42);
      expect(cubit.state.countdownSeconds, 5);
    });

    test('increment persists value and timestamp', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferencesCounterRepository repo =
          SharedPreferencesCounterRepository();
      final CounterCubit cubit = createCubit(repository: repo);
      await cubit.increment();
      final CounterSnapshot snap = await repo.load();
      expect(snap.count, 1);
      expect(snap.lastChanged, isA<DateTime>());
    });

    test(
      'persist failure emits save error without losing latest count',
      () async {
        final CounterCubit cubit = createCubit(
          repository: MockCounterRepository(shouldThrowOnSave: true),
        );

        await AppLogger.silenceAsync(() => cubit.increment());

        expect(cubit.state.count, 1);
        expect(cubit.state.status, CounterStatus.error);
        expect(cubit.state.error?.type, CounterErrorType.saveError);
      },
    );

    test(
      'countdown timer decreases deterministically (FakeTimerService)',
      () async {
        final fakeTimer = FakeTimerService();
        final CounterCubit cubit = createCubit(timerService: fakeTimer);

        // Let microtask emission happen
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final int initialCountdown = cubit.state.countdownSeconds;

        // Trigger two ticks deterministically
        fakeTimer.tick(2);

        expect(cubit.state.countdownSeconds, initialCountdown - 2);
      },
    );

    test(
      'countdown resets to 5 when it reaches 0 (FakeTimerService)',
      () async {
        final fakeTimer = FakeTimerService();
        final CounterCubit cubit = createCubit(timerService: fakeTimer);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        fakeTimer.tick(5);
        expect(cubit.state.countdownSeconds, 5);
      },
    );

    test('auto-decrement timer works (FakeTimerService)', () async {
      final fakeTimer = FakeTimerService();
      final CounterCubit cubit = createCubit(timerService: fakeTimer);
      cubit.emit(
        CounterState(
          count: 5,
          lastChanged: DateTime.now(),
          countdownSeconds: 5,
          isAutoDecrementActive: true,
        ),
      );
      // Trigger auto-decrement after 5 ticks
      fakeTimer.tick(5);
      expect(cubit.state.count, 4);
    });

    test('auto-decrement stops at 0 (FakeTimerService)', () async {
      final fakeTimer = FakeTimerService();
      final CounterCubit cubit = createCubit(timerService: fakeTimer);
      cubit.emit(
        CounterState(
          count: 1,
          lastChanged: DateTime.now(),
          countdownSeconds: 5,
          isAutoDecrementActive: true,
        ),
      );
      // Reach 0
      fakeTimer.tick(5);
      expect(cubit.state.count, 0);
      // Ensure it doesn't go below 0 on further ticks
      fakeTimer.tick(5);
      expect(cubit.state.count, 0);
    });

    test('timer resets when increment is pressed (FakeTimerService)', () async {
      final fakeTimer = FakeTimerService();
      final CounterCubit cubit = createCubit(timerService: fakeTimer);
      cubit.emit(
        CounterState(
          count: 3,
          lastChanged: DateTime.now(),
          countdownSeconds: 2,
          isAutoDecrementActive: true,
        ),
      );

      // 1 tick then increment
      fakeTimer.tick(1);
      await cubit.increment();
      expect(cubit.state.count, 4);
      expect(cubit.state.countdownSeconds, 5); // Should reset to 5

      // 3 more ticks - should not auto-decrement yet
      fakeTimer.tick(3);
      expect(cubit.state.count, 4);

      // 2 more ticks (total since increment = 5) - auto-decrement now
      fakeTimer.tick(2);
      expect(cubit.state.count, 3);
    });

    test('pauseAutoDecrement stops countdown ticks', () async {
      final fakeTimer = FakeTimerService();
      final CounterCubit cubit = createCubit(timerService: fakeTimer);
      cubit.emit(
        CounterState(
          count: 3,
          lastChanged: DateTime.now(),
          countdownSeconds: 3,
          isAutoDecrementActive: true,
        ),
      );

      fakeTimer.tick(1);
      expect(cubit.state.countdownSeconds, 2);

      cubit.pauseAutoDecrement();
      fakeTimer.tick(5);

      expect(cubit.state.count, 3);
      expect(cubit.state.countdownSeconds, 2);
    });

    test('resumeAutoDecrement restarts countdown ticks after pause', () async {
      final fakeTimer = FakeTimerService();
      final CounterCubit cubit = createCubit(timerService: fakeTimer);
      cubit.emit(
        CounterState(
          count: 2,
          lastChanged: DateTime.now(),
          countdownSeconds: 2,
          isAutoDecrementActive: true,
        ),
      );

      cubit.pauseAutoDecrement();
      fakeTimer.tick(2);
      expect(cubit.state.count, 2);

      cubit.resumeAutoDecrement();
      fakeTimer.tick(2);

      expect(cubit.state.count, 1);
      expect(
        cubit.state.countdownSeconds,
        CounterState.defaultCountdownSeconds,
      );
    });
  });
}

class _RecordingCounterRepository implements CounterRepository {
  _RecordingCounterRepository(this._initial)
    : _controller = StreamController<CounterSnapshot>.broadcast();

  CounterSnapshot _initial;
  CounterSnapshot? saved;
  final StreamController<CounterSnapshot> _controller;

  @override
  Future<CounterSnapshot> load() async => _initial;

  @override
  Future<void> save(CounterSnapshot snapshot) async {
    saved = snapshot;
    _initial = snapshot;
    _controller.add(snapshot);
  }

  @override
  Stream<CounterSnapshot> watch() async* {
    yield _initial;
    yield* _controller.stream;
  }
}
