part of 'flow_scenarios.dart';

Future<void> _openExampleDestination(
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
  // Already scrolled into view; avoid tapAndPump re-scroll.
  await tapAndPump(tester, destination, scrollIntoView: false);
}

Future<void> _openOverflowDestination(
  final WidgetTester tester,
  final String destinationLabel,
) async {
  await pumpUntilFound(tester, find.byTooltip('More'));
  await tapAndPump(tester, find.byTooltip('More'));
  final Finder destination = find.text(destinationLabel);
  await pumpUntilFound(tester, destination);
  // Popup menus on small Android emulators often clip lower items; scroll
  // the menu's own Scrollable before tap so hit-testing lands on the entry.
  final Finder menuScrollable = find.ancestor(
    of: destination,
    matching: find.byType(Scrollable),
  );
  if (tester.any(menuScrollable)) {
    await tester.scrollUntilVisible(
      destination,
      120,
      scrollable: menuScrollable.first,
    );
    // scrollUntilVisible can stop with the item flush against the bottom
    // edge (missed taps at y == viewport height). Nudge further up.
    await tester.drag(menuScrollable.first, const Offset(0, -96));
    await tester.pump(const Duration(milliseconds: 150));
  }
  // Keep nudge; tapAndPump scrollIntoView would re-scroll and can miss.
  await tapAndPump(tester, destination, scrollIntoView: false);
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
