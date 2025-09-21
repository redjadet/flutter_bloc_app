import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/counter/data/shared_preferences_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

void main() {
  group('CounterCubit', () {
    setUp(() async {
      setupSharedPreferencesMock();
    });

    test('initial state is count 0 with countdown 5', () {
      final CounterCubit cubit = CounterCubit(
        repository: SharedPreferencesCounterRepository(),
      );
      expect(cubit.state.count, 0);
      expect(cubit.state.lastChanged, isNull);
      expect(cubit.state.countdownSeconds, 5);
      cubit.close();
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
        final CounterCubit cubit = CounterCubit(
          repository: MockCounterRepository(),
        );
        cubit.emit(
          cubit.state.copyWith(
            error: const CounterError.cannotGoBelowZero(),
            status: CounterStatus.error,
          ),
        );

        cubit.clearError();

        expect(cubit.state.error, isNull);
        expect(cubit.state.status, CounterStatus.idle);
        await cubit.close();
      },
    );

    test('clearError is a no-op when no error is present', () async {
      final CounterCubit cubit = CounterCubit(
        repository: MockCounterRepository(),
      );
      final CounterState initial = cubit.state;

      cubit.clearError();

      expect(cubit.state, same(initial));
      await cubit.close();
    });

    test('loadInitial loads saved value with countdown 5', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{'last_count': 7});
      final CounterCubit cubit = CounterCubit(
        repository: SharedPreferencesCounterRepository(),
      );
      await cubit.loadInitial();
      expect(cubit.state.count, 7);
      expect(cubit.state.lastChanged, isNull);
      expect(cubit.state.countdownSeconds, 5);
      cubit.close();
    });

    test('loadInitial with mock repository loads correctly', () async {
      final mockRepo = MockCounterRepository(
        snapshot: const CounterSnapshot(count: 42, lastChanged: null),
      );
      final CounterCubit cubit = CounterCubit(repository: mockRepo);
      await cubit.loadInitial();
      expect(cubit.state.count, 42);
      expect(cubit.state.countdownSeconds, 5);
      cubit.close();
    });

    test('increment persists value and timestamp', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferencesCounterRepository repo =
          SharedPreferencesCounterRepository();
      final CounterCubit cubit = CounterCubit(repository: repo);
      await cubit.increment();
      final CounterSnapshot snap = await repo.load();
      expect(snap.count, 1);
      expect(snap.lastChanged, isA<DateTime>());
      cubit.close();
    });

    test(
      'countdown timer decreases deterministically (FakeTimerService)',
      () async {
        final fakeTimer = FakeTimerService();
        final CounterCubit cubit = CounterCubit(
          repository: MockCounterRepository(),
          timerService: fakeTimer,
        );

        // Let microtask emission happen
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final int initialCountdown = cubit.state.countdownSeconds;

        // Trigger two ticks deterministically
        fakeTimer.tick(2);

        expect(cubit.state.countdownSeconds, initialCountdown - 2);
        await cubit.close();
      },
    );

    test(
      'countdown resets to 5 when it reaches 0 (FakeTimerService)',
      () async {
        final fakeTimer = FakeTimerService();
        final CounterCubit cubit = CounterCubit(
          repository: MockCounterRepository(),
          timerService: fakeTimer,
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        fakeTimer.tick(5);
        expect(cubit.state.countdownSeconds, 5);
        await cubit.close();
      },
    );

    test('auto-decrement timer works (FakeTimerService)', () async {
      final fakeTimer = FakeTimerService();
      final CounterCubit cubit = CounterCubit(
        repository: MockCounterRepository(),
        timerService: fakeTimer,
      );
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
      await cubit.close();
    });

    test('auto-decrement stops at 0 (FakeTimerService)', () async {
      final fakeTimer = FakeTimerService();
      final CounterCubit cubit = CounterCubit(
        repository: MockCounterRepository(),
        timerService: fakeTimer,
      );
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
      await cubit.close();
    });

    test('timer resets when increment is pressed (FakeTimerService)', () async {
      final fakeTimer = FakeTimerService();
      final CounterCubit cubit = CounterCubit(
        repository: MockCounterRepository(),
        timerService: fakeTimer,
      );
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
      await cubit.close();
    });
  });
}
