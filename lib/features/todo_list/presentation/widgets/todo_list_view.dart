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

  Widget _buildListItem(final TodoItem item) {
    final itemSelectionChanged = onItemSelectionChanged;
    final deleteWithoutConfirmation = onDeleteWithoutConfirmation;
    return RepaintBoundary(
      key: ValueKey<String>('todo-${item.id}'),
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
  }

  @override
  Widget build(final BuildContext context) {
    if (items.length >= 100) {
      // Use ListView.builder for large lists (better performance)
      return ListView.builder(
        padding: context.responsiveListPadding,
        cacheExtent: 500,
        itemCount: items.length * 2 - 1,
        itemBuilder: (final context, final index) {
          if (index.isOdd) {
            return SizedBox(height: context.responsiveGapS);
          }
          final int itemIndex = index ~/ 2;
          return _buildListItem(items[itemIndex]);
        },
      );
    }

    return ListView.separated(
      padding: context.responsiveListPadding,
      cacheExtent: 500,
      itemCount: items.length,
      separatorBuilder: (final separatorContext, final separatorIndex) =>
          SizedBox(height: context.responsiveGapS),
      itemBuilder: (final itemContext, final index) =>
          _buildListItem(items[index]),
    );
  }
}
