import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CounterState.success sets success status and preserves countdown', () {
    final DateTime now = DateTime(2024, 1, 1);
    final CounterState state = CounterState.success(
      count: 3,
      lastChanged: now,
      countdownSeconds: 7,
    );

    expect(state.count, 3);
    expect(state.status, ViewStatus.success);
    expect(state.lastChanged, now);
    expect(state.countdownSeconds, 7);
  });

  test('CounterState exposes error property', () {
    const CounterState state = CounterState(
      count: 0,
      error: CounterError.cannotGoBelowZero(),
    );

    expect(state.error, isNotNull);
    expect(state.error?.type, CounterErrorType.cannotGoBelowZero);
    expect(state.error?.type.name, CounterErrorType.cannotGoBelowZero.name);
  });
}
