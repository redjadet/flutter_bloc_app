import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_item_density.dart';
import 'package:material_ui/material_ui.dart';

enum TodoItemOverflowAction { edit, delete }

Widget buildTodoItemActions({
  required BuildContext context,
  required TodoItem item,
  required bool isCompactLayout,
  required TodoItemDensity density,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  final l10n = context.l10n;
  final colors = Theme.of(context).colorScheme;

  if (isCompactLayout) {
    return PopupMenuButton<TodoItemOverflowAction>(
      tooltip: '',
      onSelected: (action) {
        if (action == TodoItemOverflowAction.edit) {
          onEdit();
        } else {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<TodoItemOverflowAction>(
          value: TodoItemOverflowAction.edit,
          child: Text(l10n.todoListEditAction),
        ),
        PopupMenuItem<TodoItemOverflowAction>(
          value: TodoItemOverflowAction.delete,
          child: Text(l10n.todoListDeleteAction),
        ),
      ],
      child: Icon(
        Icons.more_vert,
        color: colors.onSurfaceVariant,
        size:
            context.responsiveIconSize *
            density.resolve(regular: 1, compact: 0.85, phoneLandscape: 0.7),
      ),
    );
  }

  return Wrap(
    alignment: WrapAlignment.end,
    spacing: context.responsiveHorizontalGapS,
    runSpacing: context.responsiveGapXS,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Semantics(
        label: '${l10n.todoListEditAction} ${item.title}',
        button: true,
        child: PlatformAdaptive.textButton(
          context: context,
          onPressed: () {
            // check-ignore: side_effects_build - triggered by user gesture callback.
            unawaited(HapticFeedback.selectionClick());
            onEdit();
          },
          child: Icon(
            Icons.edit_outlined,
            color: colors.primary,
            size:
                context.responsiveIconSize *
                density.resolve(
                  regular: 0.9,
                  compact: 0.75,
                  phoneLandscape: 0.65,
                ),
          ),
        ),
      ),
      Semantics(
        label: '${l10n.todoListDeleteAction} ${item.title}',
        button: true,
        child: PlatformAdaptive.textButton(
          context: context,
          onPressed: () {
            // check-ignore: side_effects_build - triggered by user gesture callback.
            unawaited(HapticFeedback.mediumImpact());
            onDelete();
          },
          child: Icon(
            Icons.delete_outline,
            color: colors.error,
            size:
                context.responsiveIconSize *
                density.resolve(
                  regular: 0.9,
                  compact: 0.75,
                  phoneLandscape: 0.65,
                ),
          ),
        ),
      ),
    ],
  );
}
