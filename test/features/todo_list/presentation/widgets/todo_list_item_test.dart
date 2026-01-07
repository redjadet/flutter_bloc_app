import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TodoListItem swipe actions', () {
    late bool onToggleCalled;
    late bool onDeleteCalled;
    late bool onDeleteWithoutConfirmationCalled;
    late TodoItem? toggledItem;
    late TodoItem? deletedItem;

    setUp(() {
      onToggleCalled = false;
      onDeleteCalled = false;
      onDeleteWithoutConfirmationCalled = false;
      toggledItem = null;
      deletedItem = null;
    });

    Widget buildWidget({
      required final TodoItem item,
      final VoidCallback? onToggle,
      final VoidCallback? onEdit,
      final VoidCallback? onDelete,
      final VoidCallback? onDeleteWithoutConfirmation,
    }) {
      return MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Scaffold(
            body: TodoListItem(
              item: item,
              onToggle:
                  onToggle ??
                  () {
                    onToggleCalled = true;
                    toggledItem = item;
                  },
              onEdit: onEdit ?? () {},
              onDelete:
                  onDelete ??
                  () {
                    onDeleteCalled = true;
                    deletedItem = item;
                  },
              onDeleteWithoutConfirmation:
                  onDeleteWithoutConfirmation ??
                  () {
                    onDeleteWithoutConfirmationCalled = true;
                    deletedItem = item;
                  },
            ),
          ),
        ),
      );
    }

    testWidgets('swipe right on active item completes it', (
      final WidgetTester tester,
    ) async {
      final TodoItem activeItem = TodoItem.create(
        title: 'Active Task',
        description: null,
      );

      await tester.pumpWidget(buildWidget(item: activeItem));
      await tester.pumpAndSettle();

      final Finder dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      final Offset start = tester.getCenter(dismissible);
      final Offset end = start + const Offset(400, 0);

      // Simulate a complete swipe gesture using gesture test helpers
      final TestGesture gesture = await tester.startGesture(start);
      await gesture.moveTo(end);
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Wait for confirmDismiss async callback to complete
      await tester.pumpAndSettle();

      expect(
        onToggleCalled,
        isTrue,
        reason: 'onToggle should be called on swipe right',
      );
      expect(toggledItem, equals(activeItem));
    });

    testWidgets('swipe right on completed item uncompletes it', (
      final WidgetTester tester,
    ) async {
      final TodoItem completedItem = TodoItem.create(
        title: 'Completed Task',
        description: null,
      ).copyWith(isCompleted: true);

      await tester.pumpWidget(buildWidget(item: completedItem));
      await tester.pumpAndSettle();

      final Finder dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      final Offset start = tester.getCenter(dismissible);
      final Offset end = start + const Offset(400, 0);

      // Simulate a complete swipe gesture using gesture test helpers
      final TestGesture gesture = await tester.startGesture(start);
      await gesture.moveTo(end);
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Wait for confirmDismiss async callback to complete
      await tester.pumpAndSettle();

      expect(
        onToggleCalled,
        isTrue,
        reason: 'onToggle should be called on swipe right',
      );
      expect(toggledItem, equals(completedItem));
    });

    testWidgets('swipe right does not dismiss item', (
      final WidgetTester tester,
    ) async {
      final TodoItem item = TodoItem.create(title: 'Task', description: null);

      await tester.pumpWidget(buildWidget(item: item));
      await tester.pumpAndSettle();

      final Finder dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      final Offset start = tester.getCenter(dismissible);
      final Offset end = start + const Offset(400, 0);

      // Simulate a complete swipe gesture using gesture test helpers
      final TestGesture gesture = await tester.startGesture(start);
      await gesture.moveTo(end);
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Wait for confirmDismiss async callback to complete
      await tester.pumpAndSettle();

      expect(onToggleCalled, isTrue, reason: 'onToggle should be called');
      expect(
        dismissible,
        findsOneWidget,
        reason: 'Item should not be dismissed on right swipe',
      );
    });

    testWidgets('swipe left shows delete confirmation dialog', (
      final WidgetTester tester,
    ) async {
      final TodoItem item = TodoItem.create(
        title: 'Task to Delete',
        description: null,
      );

      await tester.pumpWidget(buildWidget(item: item));
      await tester.pumpAndSettle();

      final Finder dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      final Offset start = tester.getCenter(dismissible);
      final Offset end = start + const Offset(-400, 0);

      await tester.drag(dismissible, end - start);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      final Finder dialogFinder = find.byType(AlertDialog);
      if (dialogFinder.evaluate().isEmpty) {
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      } else {
        expect(dialogFinder, findsOneWidget);
      }
      expect(find.text('Delete todo?'), findsOneWidget);

      final Finder deleteButton = find.widgetWithText(TextButton, 'Delete');
      if (deleteButton.evaluate().isEmpty) {
        final Finder cupertinoDelete = find.widgetWithText(
          CupertinoDialogAction,
          'Delete',
        );
        expect(cupertinoDelete, findsOneWidget);
        await tester.tap(cupertinoDelete);
      } else {
        expect(deleteButton, findsOneWidget);
        await tester.tap(deleteButton);
      }
      await tester.pumpAndSettle();

      expect(onDeleteWithoutConfirmationCalled, isTrue);
      expect(deletedItem, equals(item));
    });

    testWidgets('swipe left cancel does not delete item', (
      final WidgetTester tester,
    ) async {
      final TodoItem item = TodoItem.create(
        title: 'Task to Keep',
        description: null,
      );

      await tester.pumpWidget(buildWidget(item: item));
      await tester.pumpAndSettle();

      final Finder dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      final Offset start = tester.getCenter(dismissible);
      final Offset end = start + const Offset(-400, 0);

      await tester.drag(dismissible, end - start);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      final Finder dialogFinder2 = find.byType(AlertDialog);
      if (dialogFinder2.evaluate().isEmpty) {
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      } else {
        expect(dialogFinder2, findsOneWidget);
      }

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(onDeleteWithoutConfirmationCalled, isFalse);
      expect(onDeleteCalled, isFalse);
      expect(deletedItem, isNull);
    });

    // Note: Swipe-to-complete functionality removed - completion status
    // can only be changed from the edit dialog now.

    testWidgets('swipe actions only work on mobile', (
      final WidgetTester tester,
    ) async {
      final TodoItem item = TodoItem.create(title: 'Task', description: null);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1920, 1080)),
            child: Scaffold(
              body: TodoListItem(
                item: item,
                onToggle: () {
                  onToggleCalled = true;
                },
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder dismissible = find.byType(Dismissible);
      expect(dismissible, findsNothing);
    });
  });
}
