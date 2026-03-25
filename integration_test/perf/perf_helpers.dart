import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widget_tester_pumps.dart';

Future<void> openExampleDestination(
  final WidgetTester tester,
  final String destinationLabel,
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
  final WidgetTester tester,
  final String destinationLabel,
) async {
  await pumpUntilFound(tester, find.byTooltip('More'));
  await tapAndPump(tester, find.byTooltip('More'));
  await pumpUntilFound(tester, find.text(destinationLabel));
  await tapAndPump(tester, find.text(destinationLabel));
}

Finder findAdaptiveButtonByText(final String text, {final Finder? scope}) =>
    find
        .ancestor(
          of: scope == null
              ? find.text(text)
              : find.descendant(of: scope, matching: find.text(text)),
          matching: find.byWidgetPredicate(
            (final widget) =>
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
  (final widget) => widget is AlertDialog || widget is CupertinoAlertDialog,
);

Finder findDialogTextField() {
  final Finder dialog = findDialog();
  final Finder textField = find.byWidgetPredicate(
    (final widget) => widget is TextField || widget is CupertinoTextField,
  );
  return find.descendant(of: dialog, matching: textField).first;
}

Finder findDialogCheckbox() {
  final Finder dialog = findDialog();
  final Finder checkbox = find.byWidgetPredicate(
    (final widget) => widget is Checkbox || widget is CupertinoCheckbox,
  );
  return find.descendant(of: dialog, matching: checkbox).first;
}

Finder findDialogButtonByText(final String text) =>
    findAdaptiveButtonByText(text, scope: findDialog());

Future<T> timelineTask<T>(
  final String name,
  final Future<T> Function() body,
) async {
  final dev.TimelineTask task = dev.TimelineTask()..start(name);
  try {
    return await body();
  } finally {
    task.finish();
  }
}

Finder findScrollTarget(final WidgetTester tester) {
  final List<Finder> candidates = <Finder>[
    find.byType(ListView),
    find.byType(CustomScrollView),
    find.byType(Scrollable),
  ];
  for (final candidate in candidates) {
    if (tester.any(candidate)) {
      return candidate.first;
    }
  }
  return find.byType(Scrollable).first;
}

Future<void> setSwitchListTileValue(
  final WidgetTester tester, {
  required final Finder switchTileFinder,
  required final bool value,
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
