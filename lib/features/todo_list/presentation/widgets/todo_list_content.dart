import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_empty_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_view.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class TodoListContent extends StatelessWidget {
  const TodoListContent({
    required this.filteredItems,
    required this.sortOrder,
    required this.selectedItemIds,
    required this.cubit,
    required this.onItemSelectionChanged,
    required this.onAddTodo,
    required this.onEditTodo,
    required this.onDeleteTodo,
    required this.onDeleteWithUndo,
    super.key,
  });

  final List<TodoItem> filteredItems;
  final TodoSortOrder sortOrder;
  final Set<String> selectedItemIds;
  final TodoListCubit cubit;
  final void Function(String itemId, {required bool selected})
  onItemSelectionChanged;
  final VoidCallback onAddTodo;
  final void Function(TodoItem item) onEditTodo;
  final void Function(TodoItem item) onDeleteTodo;
  final void Function(TodoItem item, TodoListCubit cubit) onDeleteWithUndo;

  @override
  Widget build(final BuildContext context) {
    if (filteredItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => cubit.refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: context.heightFraction(0.6),
            child: TodoEmptyState(
              onAddTodo: onAddTodo,
            ),
          ),
        ),
      );
    }

    if (sortOrder == TodoSortOrder.manual) {
      return RefreshIndicator(
        onRefresh: () => cubit.refresh(),
        child: ClipRect(
          child: ReorderableListView.builder(
            padding: context.responsiveListPadding,
            cacheExtent: 500,
            itemCount: filteredItems.length,
            onReorder: (final oldIndex, final newIndex) {
              cubit.reorderItems(
                oldIndex: oldIndex,
                newIndex: newIndex,
              );
            },
            itemBuilder: (final context, final index) {
              final TodoItem item = filteredItems[index];
              return RepaintBoundary(
                key: ValueKey('todo-${item.id}'),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: context.responsiveGapS,
                  ),
                  child: TodoListItem(
                    item: item,
                    showDragHandle: sortOrder == TodoSortOrder.manual,
                    isSelected: selectedItemIds.contains(item.id),
                    onSelectionChanged: (final selected) {
                      if (selected != selectedItemIds.contains(item.id)) {
                        onItemSelectionChanged(item.id, selected: selected);
                      }
                    },
                    onToggle: () => cubit.toggleTodo(item),
                    onEdit: () => onEditTodo(item),
                    onDelete: () => onDeleteTodo(item),
                    onDeleteWithoutConfirmation: () =>
                        onDeleteWithUndo(item, cubit),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => cubit.refresh(),
      child: TodoListView(
        items: filteredItems,
        sortOrder: sortOrder,
        onToggle: (final item) => cubit.toggleTodo(item),
        onEdit: (final item) => onEditTodo(item),
        onDelete: (final item) => onDeleteTodo(item),
        onDeleteWithoutConfirmation: (final item) =>
            onDeleteWithUndo(item, cubit),
        selectedItemIds: selectedItemIds,
        onItemSelectionChanged: onItemSelectionChanged,
      ),
    );
  }
}
