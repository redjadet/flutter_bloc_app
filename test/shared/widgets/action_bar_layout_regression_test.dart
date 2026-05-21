import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/layout_overflow_expectations.dart';

/// Regression: intrinsic-width action rows should use [OverflowBar] on narrow widths.
/// See tool/check_row_action_overflow.sh.
void main() {
  Future<void> pumpOverflowBarHarness(
    WidgetTester tester, {
    required double width,
  }) async {
    final previousPhysicalSize = tester.view.physicalSize;
    final previousDevicePixelRatio = tester.view.devicePixelRatio;
    addTearDown(() {
      tester.view.physicalSize = previousPhysicalSize;
      tester.view.devicePixelRatio = previousDevicePixelRatio;
    });
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 12,
            overflowSpacing: 12,
            children: <Widget>[
              TextButton(onPressed: () {}, child: const Text('Clear')),
              FilledButton(onPressed: () {}, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('OverflowBar with two buttons does not overflow at 320dp', (
    WidgetTester tester,
  ) async {
    final capture = startLayoutOverflowCapture();
    addTearDown(capture.dispose);
    await pumpOverflowBarHarness(tester, width: 320);
    expectNoRenderOverflows(capture.errors);
    expect(tester.takeException(), isNull);
    expect(find.byType(OverflowBar), findsOneWidget);
  });

  testWidgets('OverflowBar with two buttons does not overflow at 390dp', (
    WidgetTester tester,
  ) async {
    final capture = startLayoutOverflowCapture();
    addTearDown(capture.dispose);
    await pumpOverflowBarHarness(tester, width: 390);
    expectNoRenderOverflows(capture.errors);
    expect(tester.takeException(), isNull);
  });
}
