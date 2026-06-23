import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_sort_bar.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSortBar(
    final WidgetTester tester, {
    required final TodoSortOrder sortOrder,
    required final ValueChanged<TodoSortOrder> onSortChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TodoSortBar(
            sortOrder: sortOrder,
            onSortChanged: onSortChanged,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('TodoSortBar', () {
    testWidgets('shows current sort label for each order', (final tester) async {
      for (final TodoSortOrder order in TodoSortOrder.values) {
        await pumpSortBar(
          tester,
          sortOrder: order,
          onSortChanged: (_) {},
        );

        await tester.tap(find.byIcon(Icons.sort));
        await tester.pumpAndSettle();
        expect(find.byType(PopupMenuItem<TodoSortOrder>), findsWidgets);
        await tester.tapAt(Offset.zero);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('invokes onSortChanged when menu item selected', (
      final tester,
    ) async {
      TodoSortOrder? selected;
      await pumpSortBar(
        tester,
        sortOrder: TodoSortOrder.dateDesc,
        onSortChanged: (final value) => selected = value,
      );

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Title (A-Z)').last);
      await tester.pumpAndSettle();

      expect(selected, TodoSortOrder.titleAsc);
    });
  });
}
