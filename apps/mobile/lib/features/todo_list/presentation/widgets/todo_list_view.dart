import 'package:design_system/responsive.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_selectable_item.dart';
import 'package:material_ui/material_ui.dart';

/// Optimized list view for todo items.
/// Uses ListView.builder for 100+ items, ListView.separated for smaller lists.
class TodoListView extends StatelessWidget {
  const TodoListView({
    required this.items,
    required this.sortOrder,
    required this.scrollController,
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
  final ScrollController scrollController;
  final void Function(TodoItem) onToggle;
  final void Function(TodoItem) onEdit;
  final void Function(TodoItem) onDelete;
  final void Function(TodoItem)? onDeleteWithoutConfirmation;
  final Set<String> selectedItemIds;
  final void Function(String itemId, {required bool selected})?
  onItemSelectionChanged;

  Widget _buildListItem(TodoItem item) {
    final deleteWithoutConfirmation = onDeleteWithoutConfirmation;
    final itemSelectionChanged = onItemSelectionChanged;
    return RepaintBoundary(
      key: ValueKey<String>('todo-${item.id}'),
      child: itemSelectionChanged == null
          ? TodoListItem(
              item: item,
              showDragHandle: sortOrder == TodoSortOrder.manual,
              isSelected: selectedItemIds.contains(item.id),
              onToggle: () => onToggle(item),
              onEdit: () => onEdit(item),
              onDelete: () => onDelete(item),
              onDeleteWithoutConfirmation: deleteWithoutConfirmation != null
                  ? () => deleteWithoutConfirmation(item)
                  : null,
            )
          : TodoListSelectableItem(
              item: item,
              showDragHandle: sortOrder == TodoSortOrder.manual,
              onItemSelectionChanged: itemSelectionChanged,
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
  Widget build(BuildContext context) {
    if (items.length >= 100) {
      // Use ListView.builder for large lists (better performance)
      return ListView.builder(
        scrollCacheExtent: const ScrollCacheExtent.pixels(500),
        controller: scrollController,
        padding: context.responsiveListPadding,
        itemCount: items.length * 2 - 1,
        itemBuilder: (context, index) {
          if (index.isOdd) {
            return SizedBox(height: context.responsiveGapS);
          }
          final int itemIndex = index ~/ 2;
          return _buildListItem(items[itemIndex]);
        },
      );
    }

    return ListView.separated(
      scrollCacheExtent: const ScrollCacheExtent.pixels(500),
      controller: scrollController,
      padding: context.responsiveListPadding,
      itemCount: items.length,
      separatorBuilder: (separatorContext, separatorIndex) =>
          SizedBox(height: context.responsiveGapS),
      itemBuilder: (itemContext, index) => _buildListItem(items[index]),
    );
  }
}
