part of 'flow_scenarios.dart';

Future<void> _scrollDestinationIntoView(
  final WidgetTester tester,
  final Finder destination, {
  final double delta = 240,
  final double edgeNudge = -120,
}) async {
  final Finder scrollableAncestor = find.ancestor(
    of: destination,
    matching: find.byType(Scrollable),
  );
  final Finder scrollable = tester.any(scrollableAncestor)
      ? scrollableAncestor
      : find.byType(Scrollable);
  if (!tester.any(scrollable)) {
    await tester.ensureVisible(destination);
    return;
  }
  await tester.scrollUntilVisible(
    destination,
    delta,
    scrollable: scrollable.first,
  );
  // Only nudge when the target is still not hittable (flush to edge). A
  // blanket nudge can scroll already-visible mid-list items off-screen.
  if (!tester.any(destination.hitTestable())) {
    await tester.drag(scrollable.first, Offset(0, edgeNudge));
    await tester.pump(const Duration(milliseconds: 150));
  }
}

Future<bool> _tapHitTestable(
  final WidgetTester tester,
  final Finder destination,
) async {
  final Finder hittable = destination.hitTestable();
  if (!tester.any(hittable)) {
    return false;
  }
  await tester.tap(hittable.first);
  await tester.pump(const Duration(milliseconds: 200));
  return true;
}

Future<void> _openExampleDestination(
  final WidgetTester tester,
  final String destinationLabel,
) async {
  await pumpUntilFound(tester, find.byTooltip('Open example page'));
  await tapAndPump(tester, find.byTooltip('Open example page'));
  await pumpUntilFound(tester, find.text('Example Page'));

  final Finder destination = find.text(destinationLabel);
  final Finder exampleScrollable = find.byType(Scrollable).first;
  await tester.scrollUntilVisible(
    destination,
    300,
    scrollable: exampleScrollable,
  );
  if (!tester.any(destination.hitTestable())) {
    await tester.drag(exampleScrollable, const Offset(0, -100));
    await tester.pump(const Duration(milliseconds: 150));
  }
  await tapAndPump(tester, destination, scrollIntoView: false);
}

Future<void> _openOverflowDestination(
  final WidgetTester tester,
  final String destinationLabel,
) async {
  // Lower PopupMenu entries on small Android AVDs miss intermittently under
  // suite load. Retry only while the popup route stays open after a tap.
  const int maxAttempts = 3;
  final Finder menuEntries = find.byWidgetPredicate(
    (final widget) => widget is PopupMenuEntry,
  );
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    await pumpUntilFound(tester, find.byTooltip('More'));
    await tapAndPump(tester, find.byTooltip('More'));
    await pumpUntilFound(tester, menuEntries);
    final Finder destination = find.text(destinationLabel);
    await pumpUntilFound(tester, destination);
    await _scrollDestinationIntoView(
      tester,
      destination,
      delta: 120,
      edgeNudge: -120 - (attempt * 48),
    );
    final bool tapped = await _tapHitTestable(tester, destination);
    if (!tapped) {
      await tapAndPump(tester, destination, scrollIntoView: false);
    }
    await tester.pump(const Duration(milliseconds: 300));
    if (!tester.any(menuEntries)) {
      // Menu dismissed via item selection (not a dismiss tap).
      return;
    }
    // Missed: dismiss leftover menu and retry with a stronger nudge.
    await tester.tapAt(const Offset(8, 8));
    await tester.pump(const Duration(milliseconds: 250));
    if (tester.any(menuEntries)) {
      await tester.tapAt(const Offset(8, 8));
      await tester.pump(const Duration(milliseconds: 250));
    }
  }
  throw TestFailure(
    'Failed to open overflow destination "$destinationLabel" '
    'after $maxAttempts attempts',
  );
}

Future<void> _pageBack(final WidgetTester tester) async {
  final Finder cupertinoBack = find.byType(CupertinoNavigationBarBackButton);
  final Finder materialBack = find.byIcon(Icons.arrow_back);
  if (tester.any(cupertinoBack)) {
    await tapAndPump(tester, cupertinoBack.first);
    return;
  }
  if (tester.any(materialBack)) {
    await tapAndPump(tester, materialBack.first);
    return;
  }
  // Last resort: Flutter's pageBack (Cupertino-oriented).
  await tester.pageBack();
}

Finder _findAdaptiveButtonByText(
  final String text, {
  final Finder? scope,
}) => find
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

Finder _findDialog() => find.byWidgetPredicate(
  (final widget) => widget is AlertDialog || widget is CupertinoAlertDialog,
);

Finder _findDialogTextField() {
  final Finder dialog = _findDialog();
  final Finder textField = find.byWidgetPredicate(
    (final widget) => widget is TextField || widget is CupertinoTextField,
  );
  return find.descendant(of: dialog, matching: textField).first;
}

Finder _findDialogCheckbox() {
  final Finder dialog = _findDialog();
  final Finder checkbox = find.byWidgetPredicate(
    (final widget) => widget is Checkbox || widget is CupertinoCheckbox,
  );
  return find.descendant(of: dialog, matching: checkbox).first;
}

Finder _findDialogButtonByText(final String text) =>
    _findAdaptiveButtonByText(text, scope: _findDialog());
