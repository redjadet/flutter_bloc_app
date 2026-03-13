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
