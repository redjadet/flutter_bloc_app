part of 'flow_scenarios.dart';

Future<void> _scrollDestinationIntoView(
  WidgetTester tester,
  Finder destination, {
  double delta = 240,
  double edgeNudge = -120,
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
  WidgetTester tester,
  Finder destination,
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
  WidgetTester tester,
  String destinationLabel,
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
  WidgetTester tester,
  String destinationLabel,
) async {
  // Material uses PopupMenuEntry; Cupertino (iOS) uses CupertinoActionSheet.
  // Lower PopupMenu entries on small Android AVDs miss intermittently under
  // suite load. Retry only while the overflow surface stays open after a tap.
  const int maxAttempts = 3;
  final Finder menuEntries = find.byWidgetPredicate(
    (widget) =>
        widget is PopupMenuEntry || widget is CupertinoActionSheetAction,
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
    // Missed: dismiss leftover menu/sheet and retry with a stronger nudge.
    await tester.tapAt(const Offset(8, 8));
    await tester.pump(const Duration(milliseconds: 250));
    if (tester.any(menuEntries)) {
      final Finder cancel = find.text('Cancel');
      if (tester.any(cancel.hitTestable())) {
        await tapAndPump(tester, cancel.first, scrollIntoView: false);
      } else {
        await tester.tapAt(const Offset(8, 8));
        await tester.pump(const Duration(milliseconds: 250));
      }
    }
  }
  throw TestFailure(
    'Failed to open overflow destination "$destinationLabel" '
    'after $maxAttempts attempts',
  );
}

Future<void> _pageBack(WidgetTester tester) async {
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

/// Dismisses a modal bottom sheet without popping the underlying GoRouter page.
///
/// [_pageBack] prefers route chrome (Cupertino/Material back). Under go_router 18
/// that can pop the page while the sheet route is still active, disposing
/// route-scoped BlocProviders and tripping `_dependents.isEmpty`.
Future<void> _dismissModalSheet(WidgetTester tester) async {
  final Finder barrier = find.byType(ModalBarrier);
  if (tester.any(barrier)) {
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();
    return;
  }
  await tester.pageBack();
  await tester.pumpAndSettle();
}

Finder _findAdaptiveButtonByText(
  String text, {
  Finder? scope,
}) => find
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
            widget is TextButton ||
            widget is PopupMenuItem,
      ),
    )
    .first;

/// Add-todo control: header text button only when the list is non-empty and
/// tall enough; otherwise the page exposes a FAB with this tooltip. Desktop
/// Hive can retain todos across flows, so tooltip is the stable hit target.
Finder _findTodoAddControl() => find.byTooltip('Add todo');

/// Completes the current selection via the app-bar overflow menu. Prefer the
/// menu over the in-body batch bar: the bar is height-gated on desktop and
/// can be missing even when selection is active.
Future<void> _completeSelectedTodos(WidgetTester tester) async {
  final Finder completeLabel = find.text('Complete selected');
  // Prefer in-body batch bar when visible (height-gated on some devices).
  // Opening the app-bar menu while the bar is also up duplicates the label.
  if (!tester.any(completeLabel)) {
    final Finder batchOverflow = find.byTooltip(RegExp(r'\d+ selected'));
    await pumpUntilFound(tester, batchOverflow);
    await tapAndPump(tester, batchOverflow.first);
    await pumpUntilFound(tester, completeLabel);
  }
  await tapAndPump(
    tester,
    completeLabel.hitTestable().first,
    scrollIntoView: false,
  );
  await pumpSettleWithin(tester);
}

Finder _findDialog() => find.byWidgetPredicate(
  (widget) => widget is AlertDialog || widget is CupertinoAlertDialog,
);

Finder _findDialogTextField() {
  final Finder dialog = _findDialog();
  final Finder textField = find.byWidgetPredicate(
    (widget) => widget is TextField || widget is CupertinoTextField,
  );
  return find.descendant(of: dialog, matching: textField).first;
}

Finder _findDialogCheckbox() {
  final Finder dialog = _findDialog();
  final Finder checkbox = find.byWidgetPredicate(
    (widget) => widget is Checkbox || widget is CupertinoCheckbox,
  );
  return find.descendant(of: dialog, matching: checkbox).first;
}

Finder _findDialogButtonByText(String text) =>
    _findAdaptiveButtonByText(text, scope: _findDialog());
