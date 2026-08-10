import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_item.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

/// Rebuilds only this row's selection chrome for selection-only state changes.
class TodoListSelectableItem extends StatelessWidget {
  const TodoListSelectableItem({
    required this.item,
    required this.showDragHandle,
    required this.onItemSelectionChanged,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onDeleteWithoutConfirmation,
    super.key,
  });

  final TodoItem item;
  final bool showDragHandle;
  final void Function(String itemId, {required bool selected})
  onItemSelectionChanged;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onDeleteWithoutConfirmation;

  @override
  Widget build(final BuildContext context) =>
      TypeSafeBlocSelector<TodoListCubit, TodoListState, bool>(
        selector: (final state) => state.isItemSelected(item.id),
        builder: (final context, final isSelected) => TodoListItem(
          item: item,
          showDragHandle: showDragHandle,
          isSelected: isSelected,
          onSelectionChanged: (final selected) {
            if (selected != isSelected) {
              onItemSelectionChanged(item.id, selected: selected);
            }
          },
          onToggle: onToggle,
          onEdit: onEdit,
          onDelete: onDelete,
          onDeleteWithoutConfirmation: onDeleteWithoutConfirmation,
        ),
      );
}
