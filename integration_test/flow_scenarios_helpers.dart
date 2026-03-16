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
  await tapAndPump(tester, destination);
}

Future<void> _openOverflowDestination(
  final WidgetTester tester,
  final String destinationLabel,
) async {
  await pumpUntilFound(tester, find.byTooltip('More'));
  await tapAndPump(tester, find.byTooltip('More'));
  await pumpUntilFound(tester, find.text(destinationLabel));
  await tapAndPump(tester, find.text(destinationLabel));
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
