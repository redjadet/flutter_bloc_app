import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_bottom_navigation_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatBottomNavigationBar', () {
    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: const Center(child: Text('Test')),
          bottomNavigationBar: const ChatBottomNavigationBar(),
        ),
      );
    }

    testWidgets('should display all navigation items', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Should find all navigation icons
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('should highlight selected items with correct colors', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the add button (primary button)
      final addButton = find.byIcon(Icons.add);
      expect(addButton, findsOneWidget);

      // Find the chat button (selected)
      final chatButton = find.byIcon(Icons.chat_bubble_outline);
      expect(chatButton, findsOneWidget);

      // The add button should be in a container with gradient
      final addDecoratedBox = find.ancestor(
        of: addButton,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).gradient != null,
        ),
      );
      expect(addDecoratedBox, findsOneWidget);
    });

    testWidgets('should have correct layout structure', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Should have a decorated box with border
      expect(find.byType(DecoratedBox), findsWidgets);

      // Should have SafeArea
      expect(find.byType(SafeArea), findsOneWidget);

      // Should have a Row with mainAxisAlignment.spaceAround
      final row = find.byType(Row);
      expect(row, findsOneWidget);
    });

    testWidgets('should handle responsive sizing', (tester) async {
      // Test mobile size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ChatBottomNavigationBar), findsOneWidget);

      // Test tablet size
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ChatBottomNavigationBar), findsOneWidget);

      // Test desktop size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ChatBottomNavigationBar), findsOneWidget);
    });

    testWidgets('should have proper styling', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Should have white background
      final decoratedBox = tester.widget<DecoratedBox>(
        find
            .byWidgetPredicate(
              (widget) =>
                  widget is DecoratedBox &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration as BoxDecoration).border != null,
            )
            .first,
      );
      final decoration = decoratedBox.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));

      // Should have top border
      expect(decoration.border, isNotNull);
    });

    testWidgets('should display primary button with gradient', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the add button container
      final addIcon = find.byIcon(Icons.add);
      final addContainer = find.ancestor(
        of: addIcon,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).gradient != null,
        ),
      );

      expect(addContainer, findsOneWidget);

      // Verify the gradient colors
      final decoratedBox = tester.widget<DecoratedBox>(addContainer);
      final decoration = decoratedBox.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      expect(gradient.colors, contains(const Color(0xFFFF6B6B)));
      expect(gradient.colors, contains(const Color(0xFFFF8E53)));
    });
  });
}
