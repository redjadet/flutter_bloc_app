import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/helpers/todo_list_dialogs.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';

class TodoListItem extends StatelessWidget {
  const TodoListItem({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onDeleteWithoutConfirmation,
    this.showDragHandle = false,
    super.key,
  });

  final TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onDeleteWithoutConfirmation;
  final bool showDragHandle;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bool isMobile = !context.isDesktop;
    final TextStyle? titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: context.responsiveBodySize,
      decoration: item.isCompleted ? TextDecoration.lineThrough : null,
      color: item.isCompleted ? colors.onSurfaceVariant : colors.onSurface,
    );
    final TextStyle? descriptionStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: context.responsiveCaptionSize,
      color: colors.onSurfaceVariant,
    );

    final Widget cardContent = CommonCard(
      color: colors.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.responsiveCardRadius),
      ),
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveHorizontalGapM,
        vertical: context.responsiveGapXS,
      ),
      child: Row(
        children: [
          if (showDragHandle) ...[
            Icon(
              Icons.drag_handle,
              color: colors.onSurfaceVariant,
              size: context.responsiveIconSize * 0.9,
            ),
            SizedBox(width: context.responsiveHorizontalGapS),
          ],
          Checkbox.adaptive(
            value: item.isCompleted,
            onChanged: (_) => onToggle(),
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(width: context.responsiveHorizontalGapS),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: titleStyle),
                if (item.description != null &&
                    item.description!.isNotEmpty) ...[
                  SizedBox(height: context.responsiveGapXS / 2),
                  Text(item.description!, style: descriptionStyle),
                ],
              ],
            ),
          ),
          SizedBox(width: context.responsiveHorizontalGapS),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: '${l10n.todoListEditAction} ${item.title}',
                button: true,
                child: PlatformAdaptive.textButton(
                  context: context,
                  onPressed: onEdit,
                  child: Icon(
                    Icons.edit_outlined,
                    color: colors.primary,
                    size: context.responsiveIconSize * 0.9,
                  ),
                ),
              ),
              Semantics(
                label: '${l10n.todoListDeleteAction} ${item.title}',
                button: true,
                child: PlatformAdaptive.textButton(
                  context: context,
                  onPressed: onDelete,
                  child: Icon(
                    Icons.delete_outline,
                    color: colors.error,
                    size: context.responsiveIconSize * 0.9,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (!isMobile) {
      return Semantics(
        label: item.isCompleted
            ? '${item.title} - ${l10n.todoListFilterCompleted}'
            : item.title,
        value: item.description ?? '',
        button: true,
        child: cardContent,
      );
    }

    return Semantics(
      label: item.isCompleted
          ? '${item.title} - ${l10n.todoListFilterCompleted}'
          : item.title,
      value: item.description ?? '',
      button: true,
      child: Dismissible(
        key: ValueKey('todo-dismissible-${item.id}'),
        background: _buildSwipeBackground(
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
        secondaryBackground: _buildSwipeBackground(
          context: context,
          alignment: Alignment.centerRight,
          color: colors.error,
          foregroundColor: colors.onError,
          icon: Icons.delete_outline,
          label: l10n.todoListDeleteAction,
        ),
        confirmDismiss: (final DismissDirection direction) async {
          if (direction == DismissDirection.startToEnd) {
            onToggle();
            return false;
          } else {
            return _confirmDelete(context, item.title);
          }
        },
        onDismissed: (final DismissDirection direction) {
          if (direction == DismissDirection.endToStart) {
            (onDeleteWithoutConfirmation ?? onDelete)();
          }
        },
        child: cardContent,
      ),
    );
  }

  Widget _buildSwipeBackground({
    required final BuildContext context,
    required final Alignment alignment,
    required final Color color,
    required final Color foregroundColor,
    required final IconData icon,
    required final String label,
  }) => Container(
    alignment: alignment,
    padding: EdgeInsets.symmetric(
      horizontal: context.responsiveHorizontalGapL,
    ),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(context.responsiveCardRadius),
    ),
    child: Row(
      mainAxisAlignment: alignment == Alignment.centerLeft
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            color: foregroundColor,
            fontSize: context.responsiveBodySize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: context.responsiveHorizontalGapS),
        Icon(
          icon,
          color: foregroundColor,
          size: context.responsiveIconSize * 1.5,
        ),
      ],
    ),
  );

  Future<bool> _confirmDelete(
    final BuildContext context,
    final String title,
  ) async {
    final bool? shouldDelete = await showTodoDeleteConfirmDialog(
      context: context,
      title: title,
    );
    return shouldDelete ?? false;
  }
}
