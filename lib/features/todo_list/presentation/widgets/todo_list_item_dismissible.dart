import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/helpers/todo_list_dialogs.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_item_swipe.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';

/// Wraps a todo item widget with dismissible functionality for mobile devices.
Widget buildTodoItemDismissible({
  required final BuildContext context,
  required final TodoItem item,
  required final Widget child,
  required final VoidCallback onToggle,
  required final VoidCallback onDelete,
  final VoidCallback? onDeleteWithoutConfirmation,
}) {
  final l10n = context.l10n;
  final colors = Theme.of(context).colorScheme;

  Future<bool> confirmDelete(
    final BuildContext context,
    final String title,
  ) async {
    final bool? shouldDelete = await showTodoDeleteConfirmDialog(
      context: context,
      title: title,
    );
    return shouldDelete ?? false;
  }

  return Semantics(
    label: item.isCompleted
        ? '${item.title} - ${l10n.todoListFilterCompleted}'
        : item.title,
    value: item.description ?? '',
    button: true,
    child: Dismissible(
      key: ValueKey('todo-dismissible-${item.id}'),
      background: buildTodoSwipeBackground(
        context: context,
        alignment: Alignment.centerLeft,
        color: colors.primary,
        foregroundColor: colors.onPrimary,
        icon: item.isCompleted
            ? Icons.undo_outlined
            : Icons.check_circle_outline,
        label: item.isCompleted
            ? l10n.todoListUndoAction
            : l10n.todoListCompleteAction,
      ),
      secondaryBackground: buildTodoSwipeBackground(
        context: context,
        alignment: Alignment.centerRight,
        color: colors.error,
        foregroundColor: colors.onError,
        icon: Icons.delete_outline,
        label: l10n.todoListDeleteAction,
      ),
      confirmDismiss: (final DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          // check-ignore: side_effects_build - triggered by user gesture callback.
          unawaited(HapticFeedback.selectionClick());
          onToggle();
          return false;
        } else {
          // check-ignore: side_effects_build - triggered by user gesture callback.
          unawaited(HapticFeedback.mediumImpact());
          return confirmDelete(context, item.title);
        }
      },
      onDismissed: (final DismissDirection direction) {
        if (direction == DismissDirection.endToStart) {
          // check-ignore: side_effects_build - triggered by user gesture callback.
          unawaited(HapticFeedback.mediumImpact());
          (onDeleteWithoutConfirmation ?? onDelete)();
        }
      },
      child: child,
    ),
  );
}
