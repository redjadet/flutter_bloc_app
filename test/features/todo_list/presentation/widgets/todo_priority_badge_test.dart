import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_priority_badge.dart';
import 'package:flutter_bloc_app/shared/responsive/responsive_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TodoPriorityBadge', () {
    Widget buildTestWidget(final TodoPriority priority) {
      return MaterialApp(
        home: ResponsiveScope(
          child: Scaffold(body: TodoPriorityBadge(priority: priority)),
        ),
      );
    }

    testWidgets('renders nothing for none priority', (final tester) async {
      await tester.pumpWidget(buildTestWidget(TodoPriority.none));

      expect(find.byType(TodoPriorityBadge), findsOneWidget);
      expect(find.byType(Container), findsNothing);
      expect(find.text(''), findsNothing);
    });

    testWidgets('renders badge for low priority', (final tester) async {
      await tester.pumpWidget(buildTestWidget(TodoPriority.low));

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('renders badge for medium priority', (final tester) async {
      await tester.pumpWidget(buildTestWidget(TodoPriority.medium));

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('renders badge for high priority', (final tester) async {
      await tester.pumpWidget(buildTestWidget(TodoPriority.high));

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('applies correct styling', (final tester) async {
      await tester.pumpWidget(buildTestWidget(TodoPriority.high));

      final Container container = tester.widget(find.byType(Container));
      expect(container.decoration, isA<BoxDecoration>());
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
      expect(decoration.border, isNotNull);
    });
  });
}
