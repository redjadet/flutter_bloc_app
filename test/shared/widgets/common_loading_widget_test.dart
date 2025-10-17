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
      expect(find.byType(Container), findsOneWidget);
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

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.color, equals(Colors.black.withValues(alpha: 0.3)));
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
}
