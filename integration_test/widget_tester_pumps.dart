import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpUntilFound(
  final WidgetTester tester,
  final Finder finder, {
  final Duration timeout = const Duration(seconds: 5),
  final Duration step = const Duration(milliseconds: 100),
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    await tester.pump(step);
    if (tester.any(finder)) {
      return;
    }
  }

  throw TestFailure('Did not find $finder within ${timeout.inSeconds}s');
}

/// Pumps until [finder] is gone or [timeout] elapses (throws on timeout).
Future<void> pumpUntilAbsent(
  final WidgetTester tester,
  final Finder finder, {
  final Duration timeout = const Duration(seconds: 5),
  final Duration step = const Duration(milliseconds: 50),
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    await tester.pump(step);
    if (!tester.any(finder)) {
      return;
    }
  }

  throw TestFailure('Still found $finder after ${timeout.inSeconds}s');
}

/// Bounded [WidgetTester.pumpAndSettle] — avoids the default long timeout when
/// animations should finish quickly (integration runs).
Future<void> pumpSettleWithin(
  final WidgetTester tester, {
  final Duration step = const Duration(milliseconds: 50),
  final Duration timeout = const Duration(seconds: 3),
}) async {
  await tester.pumpAndSettle(
    step,
    EnginePhase.sendSemanticsUpdate,
    timeout,
  );
}

/// Pumps until the [Scrollable] under [scrollViewFinder] (e.g. a
/// [CustomScrollView]) reports idle via [ScrollPosition.isScrollingNotifier],
/// or until [timeout].
///
/// Use after [WidgetTester.fling] so the next fling does not stack on in-flight
/// scroll physics (avoids simulator flakiness). Falls back to [pumpSettleWithin]
/// if no descendant [Scrollable] is found.
Future<void> pumpUntilScrollIdle(
  final WidgetTester tester,
  final Finder scrollViewFinder, {
  final Duration step = const Duration(milliseconds: 50),
  final Duration timeout = const Duration(seconds: 4),
}) async {
  final Finder scrollableFinder = find.descendant(
    of: scrollViewFinder,
    matching: find.byType(Scrollable),
  );

  if (!tester.any(scrollableFinder)) {
    await pumpSettleWithin(tester, step: step, timeout: timeout);
    return;
  }

  final Stopwatch stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    await tester.pump(step);
    final ScrollableState state = tester.state<ScrollableState>(
      scrollableFinder.first,
    );
    if (!state.position.isScrollingNotifier.value) {
      return;
    }
  }

  throw TestFailure(
    'Scrollable did not become idle within ${timeout.inSeconds}s',
  );
}

/// Bounded post-[WidgetTester.fling] stabilization for scroll views.
Future<void> pumpAfterScrollFling(
  final WidgetTester tester,
  final Finder scrollViewFinder, {
  final Duration step = const Duration(milliseconds: 50),
  final Duration timeout = const Duration(seconds: 4),
}) async {
  await pumpUntilScrollIdle(
    tester,
    scrollViewFinder,
    step: step,
    timeout: timeout,
  );
}

Future<void> tapAndPump(
  final WidgetTester tester,
  final Finder finder, {
  final Duration settle = const Duration(milliseconds: 100),
}) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump(settle);
}
