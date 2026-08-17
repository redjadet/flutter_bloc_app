import 'package:design_system/responsive.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_empty_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_selectable_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_view.dart';
import 'package:material_ui/material_ui.dart';

class TodoListContent extends StatelessWidget {
  const TodoListContent({
    required this.filteredItems,
    required this.sortOrder,
    required this.scrollController,
    required this.cubit,
    required this.onAddTodo,
    required this.onEditTodo,
    required this.onDeleteTodo,
    required this.onDeleteWithUndo,
    this.selectedItemIds = const <String>{},
    this.onItemSelectionChanged,
    super.key,
  });

  final List<TodoItem> filteredItems;
  final TodoSortOrder sortOrder;
  final ScrollController scrollController;
  final TodoListCubit cubit;
  final VoidCallback onAddTodo;
  final void Function(TodoItem item) onEditTodo;
  final void Function(TodoItem item) onDeleteTodo;
  final void Function(TodoItem item, TodoListCubit cubit) onDeleteWithUndo;
  final Set<String> selectedItemIds;
  final void Function(String itemId, {required bool selected})?
  onItemSelectionChanged;

  @override
  Widget build(BuildContext context) {
    if (filteredItems.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => RefreshIndicator(
          onRefresh: () => cubit.refresh(),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(child: TodoEmptyState(onAddTodo: onAddTodo)),
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
            scrollCacheExtent: const ScrollCacheExtent.pixels(500),
            scrollController: scrollController,
            padding: context.responsiveListPadding,
            itemCount: filteredItems.length,
            onReorderItem: (oldIndex, newIndex) {
              cubit.reorderItems(oldIndex: oldIndex, newIndex: newIndex);
            },
            itemBuilder: (context, index) {
              final TodoItem item = filteredItems[index];
              final itemSelectionChanged = onItemSelectionChanged;
              return RepaintBoundary(
                key: ValueKey('todo-${item.id}'),
                child: Padding(
                  padding: EdgeInsets.only(bottom: context.responsiveGapS),
                  child: itemSelectionChanged == null
                      ? TodoListItem(
                          item: item,
                          showDragHandle: true,
                          isSelected: selectedItemIds.contains(item.id),
                          onToggle: () => cubit.toggleTodo(item),
                          onEdit: () => onEditTodo(item),
                          onDelete: () => onDeleteTodo(item),
                          onDeleteWithoutConfirmation: () =>
                              onDeleteWithUndo(item, cubit),
                        )
                      : TodoListSelectableItem(
                          item: item,
                          showDragHandle: true,
                          onItemSelectionChanged: itemSelectionChanged,
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
        scrollController: scrollController,
        onToggle: (item) => cubit.toggleTodo(item),
        onEdit: (item) => onEditTodo(item),
        onDelete: (item) => onDeleteTodo(item),
        onDeleteWithoutConfirmation: (item) => onDeleteWithUndo(item, cubit),
        selectedItemIds: selectedItemIds,
        onItemSelectionChanged: onItemSelectionChanged,
      ),
    );
  }
}
