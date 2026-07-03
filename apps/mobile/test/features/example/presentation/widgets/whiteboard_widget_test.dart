import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/whiteboard/whiteboard_painter.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/whiteboard/whiteboard_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WhiteboardWidget', () {
    testWidgets('renders toolbar and canvas', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WhiteboardWidget())),
      );

      expect(find.text('Stroke width'), findsOneWidget);
      expect(find.text('Pen color'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Redo'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      // Verify preset width buttons are present
      expect(find.text('Thin'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Thick'), findsOneWidget);
    });

    testWidgets('renders canvas for drawing', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WhiteboardWidget())),
      );

      // Verify the canvas is present (CustomPaint is used for drawing)
      expect(find.byType(CustomPaint), findsWidgets);

      // Verify toolbar elements
      expect(find.text('Stroke width'), findsOneWidget);
    });

    testWidgets('clear button is present and tappable', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WhiteboardWidget())),
      );

      // Verify clear button exists
      final Finder clearButton = find.text('Clear');
      expect(clearButton, findsOneWidget);

      // Tap clear button
      await tester.tap(clearButton);
      await tester.pump();

      // Canvas should still exist (may be multiple CustomPaint widgets in the tree)
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('draws strokes and supports undo/redo', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WhiteboardWidget())),
      );

      final Finder canvas = find.byWidgetPredicate(
        (final Widget widget) =>
            widget is CustomPaint && widget.painter is WhiteboardPainter,
      );
      expect(canvas, findsOneWidget);

      final Offset start = tester.getCenter(canvas);
      final TestGesture gesture = await tester.startGesture(start);
      await gesture.moveBy(const Offset(20, 0));
      await gesture.up();
      await tester.pump();

      CustomPaint paintWidget = tester.widget<CustomPaint>(canvas);
      WhiteboardPainter painter = paintWidget.painter! as WhiteboardPainter;
      expect(painter.strokes.length, 1);

      await tester.tap(find.text('Undo'));
      await tester.pump();
      paintWidget = tester.widget<CustomPaint>(canvas);
      painter = paintWidget.painter! as WhiteboardPainter;
      expect(painter.strokes.isEmpty, isTrue);

      await tester.tap(find.text('Redo'));
      await tester.pump();
      paintWidget = tester.widget<CustomPaint>(canvas);
      painter = paintWidget.painter! as WhiteboardPainter;
      expect(painter.strokes.length, 1);
    });
  });
}
