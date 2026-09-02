import 'dart:developer' as dev;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../widget_tester_pumps.dart';

Future<void> openExampleDestination(
  WidgetTester tester,
  String destinationLabel,
) async {
  await pumpUntilFound(tester, find.byTooltip('Open example page'));
  await tapAndPump(tester, find.byTooltip('Open example page'));
  await pumpUntilFound(tester, find.text('Example Page'));

  final Finder destination = find.text(destinationLabel);
  await tester.scrollUntilVisible(
    destination,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tapAndPump(tester, destination);
}

Future<void> openOverflowDestination(
  WidgetTester tester,
  String destinationLabel,
) async {
  await pumpUntilFound(tester, find.byTooltip('More'));
  await tapAndPump(tester, find.byTooltip('More'));
  await pumpUntilFound(tester, find.text(destinationLabel));
  await tapAndPump(tester, find.text(destinationLabel));
}

Finder findAdaptiveButtonByText(String text, {Finder? scope}) => find
    .ancestor(
      of: scope == null
          ? find.text(text)
          : find.descendant(of: scope, matching: find.text(text)),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is CupertinoButton ||
            widget is CupertinoDialogAction ||
            widget is ElevatedButton ||
            widget is FilledButton ||
            widget is FloatingActionButton ||
            widget is IconButton ||
            widget is OutlinedButton ||
            widget is TextButton,
      ),
    )
    .first;

Finder findDialog() => find.byWidgetPredicate(
  (widget) => widget is AlertDialog || widget is CupertinoAlertDialog,
);

Finder findDialogTextField() {
  final Finder dialog = findDialog();
  final Finder textField = find.byWidgetPredicate(
    (widget) => widget is TextField || widget is CupertinoTextField,
  );
  return find.descendant(of: dialog, matching: textField).first;
}

Finder findDialogCheckbox() {
  final Finder dialog = findDialog();
  final Finder checkbox = find.byWidgetPredicate(
    (widget) => widget is Checkbox || widget is CupertinoCheckbox,
  );
  return find.descendant(of: dialog, matching: checkbox).first;
}

Finder findDialogButtonByText(String text) =>
    findAdaptiveButtonByText(text, scope: findDialog());

Future<T> timelineTask<T>(
  String name,
  Future<T> Function() body,
) async {
  final dev.TimelineTask task = dev.TimelineTask()..start(name);
  try {
    return await body();
  } finally {
    task.finish();
  }
}

Finder findScrollTarget(WidgetTester tester) {
  final List<Finder> candidates = <Finder>[
    find.byType(ListView),
    find.byType(CustomScrollView),
    find.byType(Scrollable),
  ];
  for (final Finder candidate in candidates) {
    if (tester.any(candidate)) {
      return candidate.first;
    }
  }
  throw TestFailure('findScrollTarget: no scrollable widget on screen');
}

/// Waits until a list or scrollable is mounted, then returns [findScrollTarget].
///
/// [timeout] is the total budget across all scrollable candidates, not per
/// candidate.
Future<Finder> awaitScrollTarget(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final List<Finder> candidates = <Finder>[
    find.byType(ListView),
    find.byType(CustomScrollView),
    find.byType(Scrollable),
  ];
  final Stopwatch stopwatch = Stopwatch()..start();
  for (final Finder candidate in candidates) {
    final Duration remaining = timeout - stopwatch.elapsed;
    if (remaining <= Duration.zero) {
      break;
    }
    try {
      await pumpUntilFound(tester, candidate, timeout: remaining);
      return candidate.first;
    } on TestFailure {
      continue;
    }
  }
  throw TestFailure('awaitScrollTarget: no scrollable widget within timeout');
}

Future<void> setSwitchListTileValue(
  WidgetTester tester, {
  required Finder switchTileFinder,
  required bool value,
}) async {
  final SwitchListTile tile = tester.widget<SwitchListTile>(switchTileFinder);
  if (tile.value == value) {
    return;
  }
  await tapAndPump(
    tester,
    switchTileFinder,
    settle: const Duration(milliseconds: 200),
  );
  await tester.pump(const Duration(milliseconds: 100));
}
