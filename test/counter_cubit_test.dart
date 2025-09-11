import 'package:bloc_test/bloc_test.dart';
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
      final CounterCubit cubit = CounterCubit();
      expect(cubit.state.count, 0);
      expect(cubit.state.lastChanged, isNull);
      expect(cubit.state.countdownSeconds, 5);
      cubit.close();
    });

    blocTest<CounterCubit, CounterState>(
      'emits state with count 1 and lastChanged set on increment',
      build: () => CounterCubit(),
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
      skip: 1, // Skip the initial countdown timer emission
    );

    blocTest<CounterCubit, CounterState>(
      'does not go below 0 and emits error on decrement at 0',
      build: () => CounterCubit(),
      act: (cubit) => cubit.decrement(),
      expect: () => [
        isA<CounterState>()
            .having((s) => s.count, 'count', 0)
            .having((s) => s.error, 'errorMessage', 'cannotGoBelowZero'),
      ],
      skip: 1, // Skip the initial countdown timer emission
    );

    test('loadInitial loads saved value with countdown 5', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{'last_count': 7});
      final CounterCubit cubit = CounterCubit();
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
      final CounterCubit cubit = CounterCubit();
      await cubit.increment();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('last_count'), 1);
      expect(prefs.getInt('last_changed'), isA<int>());
      cubit.close();
    });

    test('countdown timer decreases every second', () async {
      final CounterCubit cubit = CounterCubit();
      // Wait for initial setup
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final int initialCountdown = cubit.state.countdownSeconds;

      // Wait 2 seconds
      await Future<void>.delayed(const Duration(seconds: 2));

      expect(cubit.state.countdownSeconds, initialCountdown - 2);
      cubit.close();
    });

    test('countdown resets to 5 when it reaches 0', () async {
      final CounterCubit cubit = CounterCubit();
      // Wait for initial setup
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Wait for countdown to reach 0 and reset
      await Future<void>.delayed(const Duration(seconds: 6));

      expect(cubit.state.countdownSeconds, 5);
      cubit.close();
    });

    test('auto-decrement timer works', () async {
      final CounterCubit cubit = CounterCubit();
      cubit.emit(
        CounterState(
          count: 5,
          lastChanged: DateTime.now(),
          countdownSeconds: 5,
        ),
      );

      // Wait for auto-decrement (5 seconds)
      await Future<void>.delayed(const Duration(seconds: 6));

      expect(cubit.state.count, 4);
      cubit.close();
    });

    test('auto-decrement stops at 0', () async {
      final CounterCubit cubit = CounterCubit();
      cubit.emit(
        CounterState(
          count: 1,
          lastChanged: DateTime.now(),
          countdownSeconds: 5,
        ),
      );

      // Wait for auto-decrement to reach 0
      await Future<void>.delayed(const Duration(seconds: 6));
      expect(cubit.state.count, 0);

      // Wait another 5 seconds to ensure it doesn't go below 0
      await Future<void>.delayed(const Duration(seconds: 6));
      expect(cubit.state.count, 0);

      cubit.close();
    });

    test('timer resets when increment is pressed', () async {
      final CounterCubit cubit = CounterCubit();
      cubit.emit(
        CounterState(
          count: 3,
          lastChanged: DateTime.now(),
          countdownSeconds: 2,
        ),
      );

      // Wait 1 second, then increment
      await Future<void>.delayed(const Duration(seconds: 1));
      await cubit.increment();
      expect(cubit.state.count, 4);
      expect(cubit.state.countdownSeconds, 5); // Should reset to 5

      // Wait 3 more seconds - should not auto-decrement yet
      await Future<void>.delayed(const Duration(seconds: 3));
      expect(cubit.state.count, 4);

      // Wait 3 more seconds - should auto-decrement now
      await Future<void>.delayed(const Duration(seconds: 3));
      expect(cubit.state.count, 3);

      cubit.close();
    });
  });
}
