import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommonLoadingWidget', () {
    testWidgets('renders circular progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CommonLoadingWidget())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CommonLoadingWidget), findsOneWidget);
    });

    testWidgets('renders with custom message', (tester) async {
      const message = 'Loading data...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CommonLoadingWidget(message: message)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('does not render message when null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CommonLoadingWidget())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('centers content vertically and horizontally', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CommonLoadingWidget())),
      );

      final centerWidget = find.byType(Center);
      expect(centerWidget, findsOneWidget);
    });

    testWidgets('applies secondary color to progress indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(secondary: Colors.blue),
          ),
          home: const Scaffold(body: CommonLoadingWidget()),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progressIndicator.color, equals(Colors.blue));
    });

    testWidgets('applies custom color when provided', (tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CommonLoadingWidget(color: customColor)),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progressIndicator.color, equals(customColor));
    });

    testWidgets('applies custom size when provided', (tester) async {
      const customSize = 48.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CommonLoadingWidget(size: customSize)),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(Column),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.width, equals(customSize));
      expect(sizedBox.height, equals(customSize));
    });

    testWidgets('uses default size when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CommonLoadingWidget())),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(Column),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.width, equals(24.0));
      expect(sizedBox.height, equals(24.0));
    });
  });

  group('CommonLoadingOverlay', () {
    testWidgets('shows overlay when loading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonLoadingOverlay(isLoading: true, child: Text('Content')),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Find the ColoredBox that's a descendant of the Stack (the overlay)
      final stackFinder = find.byType(Stack);
      final coloredBoxFinder = find.descendant(
        of: stackFinder,
        matching: find.byType(ColoredBox),
      );
      expect(coloredBoxFinder, findsOneWidget);
    });

    testWidgets('hides overlay when loading is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonLoadingOverlay(
              isLoading: false,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows custom message in overlay', (tester) async {
      const message = 'Processing...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonLoadingOverlay(
              isLoading: true,
              message: message,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text(message), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('applies semi-transparent background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonLoadingOverlay(isLoading: true, child: Text('Content')),
          ),
        ),
      );

      // Find the ColoredBox that's a descendant of the Stack (the overlay)
      final stackFinder = find.byType(Stack);
      final coloredBoxFinder = find.descendant(
        of: stackFinder,
        matching: find.byType(ColoredBox),
      );
      expect(coloredBoxFinder, findsOneWidget);

      final coloredBox = tester.widget<ColoredBox>(coloredBoxFinder);
      expect(coloredBox.color, equals(Colors.black.withValues(alpha: 0.3)));
    });

    testWidgets('maintains child widget when not loading', (tester) async {
      const child = Text('Main Content');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonLoadingOverlay(isLoading: false, child: child),
          ),
        ),
      );

      expect(find.text('Main Content'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CommonLoadingOverlay),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });
  });

  group('CommonLoadingButton', () {
    testWidgets('renders child when not loading', (tester) async {
      const child = Text('Submit');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingButton(onPressed: () {}, child: child),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingButton(
              onPressed: () {},
              isLoading: true,
              child: const Text('Submit'),
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsNothing);
      // Should show either CircularProgressIndicator or CupertinoActivityIndicator
      final hasMaterialIndicator = find
          .byType(CircularProgressIndicator)
          .evaluate()
          .isNotEmpty;
      final hasCupertinoIndicator = find
          .byType(CupertinoActivityIndicator)
          .evaluate()
          .isNotEmpty;
      expect(hasMaterialIndicator || hasCupertinoIndicator, isTrue);
    });

    testWidgets('disables button when loading', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingButton(
              onPressed: () {
                wasPressed = true;
              },
              isLoading: true,
              child: const Text('Submit'),
            ),
          ),
        ),
      );

      final button = find.byType(CommonLoadingButton);
      await tester.tap(button);
      await tester.pump();

      expect(wasPressed, isFalse);
    });

    testWidgets('enables button when not loading', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingButton(
              onPressed: () {
                wasPressed = true;
              },
              isLoading: false,
              child: const Text('Submit'),
            ),
          ),
        ),
      );

      final button = find.byType(CommonLoadingButton);
      await tester.tap(button);
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('shows loading message when provided', (tester) async {
      const loadingMessage = 'Processing...';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingButton(
              onPressed: () {},
              isLoading: true,
              loadingMessage: loadingMessage,
              child: const Text('Submit'),
            ),
          ),
        ),
      );

      expect(find.text(loadingMessage), findsOneWidget);
    });

    testWidgets('does not show loading message when null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingButton(
              onPressed: () {},
              isLoading: true,
              child: const Text('Submit'),
            ),
          ),
        ),
      );

      // Should not find any text except possibly button text
      final textWidgets = find.byType(Text);
      expect(textWidgets, findsNothing);
    });

    testWidgets('handles null onPressed callback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingButton(
              onPressed: null,
              child: const Text('Submit'),
            ),
          ),
        ),
      );

      final button = find.byType(CommonLoadingButton);
      await tester.tap(button);
      await tester.pump();

      // Should not crash
      expect(find.text('Submit'), findsOneWidget);
    });
  });
}
