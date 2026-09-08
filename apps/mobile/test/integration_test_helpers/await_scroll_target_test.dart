import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/perf/perf_helpers.dart';

void main() {
  testWidgets('awaitScrollTarget finds GridView when ListView is absent', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GridView.count(
            crossAxisCount: 2,
            children: const <Widget>[
              ColoredBox(color: Colors.red),
              ColoredBox(color: Colors.blue),
            ],
          ),
        ),
      ),
    );

    final Finder scrollTarget = await awaitScrollTarget(
      tester,
      timeout: const Duration(seconds: 2),
    );

    expect(tester.widget(scrollTarget), isA<GridView>());
    expect(find.byType(ListView), findsNothing);
  });
}
