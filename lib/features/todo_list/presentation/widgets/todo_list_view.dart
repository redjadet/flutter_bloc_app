import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_item.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Optimized list view for todo items.
/// Uses ListView.builder for 100+ items, ListView.separated for smaller lists.
class TodoListView extends StatelessWidget {
  const TodoListView({
    required this.items,
    required this.sortOrder,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onDeleteWithoutConfirmation,
    this.selectedItemIds = const <String>{},
    this.onItemSelectionChanged,
    super.key,
  });

  final List<TodoItem> items;
  final TodoSortOrder sortOrder;
  final void Function(TodoItem) onToggle;
  final void Function(TodoItem) onEdit;
  final void Function(TodoItem) onDelete;
  final void Function(TodoItem)? onDeleteWithoutConfirmation;
  final Set<String> selectedItemIds;
  final void Function(String itemId, {required bool selected})?
  onItemSelectionChanged;

  @override
  Widget build(final BuildContext context) {
    final itemSelectionChanged = onItemSelectionChanged;
    final deleteWithoutConfirmation = onDeleteWithoutConfirmation;

    if (items.length >= 100) {
      // Use ListView.builder for large lists (better performance)
      return ListView.builder(
        padding: context.responsiveListPadding,
        cacheExtent: 500,
        itemCount: items.length * 2 - 1,
        itemBuilder: (final context, final index) {
          // Even indices are items, odd indices are separators
          if (index.isOdd) {
            return SizedBox(height: context.responsiveGapS);
          }
          final int itemIndex = index ~/ 2;
          final TodoItem item = items[itemIndex];
          return RepaintBoundary(
            key: ValueKey('todo-${item.id}'),
            child: TodoListItem(
              item: item,
              showDragHandle: sortOrder == TodoSortOrder.manual,
              isSelected: selectedItemIds.contains(item.id),
              onSelectionChanged: itemSelectionChanged != null
                  ? (final selected) =>
                        itemSelectionChanged(item.id, selected: selected)
                  : null,
              onToggle: () => onToggle(item),
              onEdit: () => onEdit(item),
              onDelete: () => onDelete(item),
              onDeleteWithoutConfirmation: deleteWithoutConfirmation != null
                  ? () => deleteWithoutConfirmation(item)
                  : null,
            ),
          );
        },
      );
    }

    // Use ListView.separated for smaller lists (simpler code)
    return ListView.separated(
      padding: context.responsiveListPadding,
      cacheExtent: 500,
      itemCount: items.length,
      separatorBuilder: (final _, final _) =>
          SizedBox(height: context.responsiveGapS),
      itemBuilder: (final context, final index) {
        final TodoItem item = items[index];
        return RepaintBoundary(
          key: ValueKey('todo-${item.id}'),
          child: TodoListItem(
            item: item,
            showDragHandle: sortOrder == TodoSortOrder.manual,
            isSelected: selectedItemIds.contains(item.id),
            onSelectionChanged: itemSelectionChanged != null
                ? (final selected) =>
                      itemSelectionChanged(item.id, selected: selected)
                : null,
            onToggle: () => onToggle(item),
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item),
            onDeleteWithoutConfirmation: deleteWithoutConfirmation != null
                ? () => deleteWithoutConfirmation(item)
                : null,
          ),
        );
      },
    );
  }
}
