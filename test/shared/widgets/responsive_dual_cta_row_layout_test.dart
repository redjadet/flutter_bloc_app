import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/shared/widgets/responsive_action_bar.dart';

import '../../helpers/layout_overflow_expectations.dart';

void main() {
  group('ResponsiveDualCtaRow', () {
    Widget buildActionRow() {
      return ResponsiveDualCtaRow(
        start: OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
        end: FilledButton(onPressed: () {}, child: const Text('Confirm')),
      );
    }

    Widget buildSubject({final Widget? child}) {
      return MaterialApp(
        home: Scaffold(body: Center(child: child ?? buildActionRow())),
      );
    }

    testWidgets('uses Row with Expanded at 400dp without overflow', (
      tester,
    ) async {
      final capture = startLayoutOverflowCapture();
      addTearDown(capture.dispose);

      final previousPhysicalSize = tester.view.physicalSize;
      final previousDevicePixelRatio = tester.view.devicePixelRatio;
      addTearDown(() {
        tester.view.physicalSize = previousPhysicalSize;
        tester.view.devicePixelRatio = previousDevicePixelRatio;
      });
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Expanded), findsNWidgets(2));
      expectNoRenderOverflows(capture.errors);
    });

    testWidgets('stacks in Column at 320dp without overflow', (tester) async {
      final capture = startLayoutOverflowCapture();
      addTearDown(capture.dispose);

      final previousPhysicalSize = tester.view.physicalSize;
      final previousDevicePixelRatio = tester.view.devicePixelRatio;
      addTearDown(() {
        tester.view.physicalSize = previousPhysicalSize;
        tester.view.devicePixelRatio = previousDevicePixelRatio;
      });
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsNothing);
      expectNoRenderOverflows(capture.errors);
    });

    testWidgets('stacks when parent constraint is narrow on wide screen', (
      tester,
    ) async {
      final capture = startLayoutOverflowCapture();
      addTearDown(capture.dispose);

      final previousPhysicalSize = tester.view.physicalSize;
      final previousDevicePixelRatio = tester.view.devicePixelRatio;
      addTearDown(() {
        tester.view.physicalSize = previousPhysicalSize;
        tester.view.devicePixelRatio = previousDevicePixelRatio;
      });
      tester.view.physicalSize = const Size(1024, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildSubject(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 320, child: buildActionRow()),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsNothing);
      expectNoRenderOverflows(capture.errors);
    });
  });
}
