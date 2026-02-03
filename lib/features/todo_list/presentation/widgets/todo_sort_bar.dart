import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class TodoSortBar extends StatelessWidget {
  const TodoSortBar({
    required this.sortOrder,
    required this.onSortChanged,
    super.key,
  });

  final TodoSortOrder sortOrder;
  final ValueChanged<TodoSortOrder> onSortChanged;

  String _getSortLabel(final BuildContext context) => switch (sortOrder) {
    TodoSortOrder.dateDesc => context.l10n.todoListSortDateDesc,
    TodoSortOrder.dateAsc => context.l10n.todoListSortDateAsc,
    TodoSortOrder.titleAsc => context.l10n.todoListSortTitleAsc,
    TodoSortOrder.titleDesc => context.l10n.todoListSortTitleDesc,
    TodoSortOrder.priorityDesc => context.l10n.todoListSortPriorityDesc,
    TodoSortOrder.priorityAsc => context.l10n.todoListSortPriorityAsc,
    TodoSortOrder.dueDateAsc => context.l10n.todoListSortDueDateAsc,
    TodoSortOrder.dueDateDesc => context.l10n.todoListSortDueDateDesc,
    TodoSortOrder.manual => context.l10n.todoListSortManual,
  };

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final String sortLabel = _getSortLabel(context);

    return PopupMenuButton<TodoSortOrder>(
      tooltip: context.l10n.todoListSortAction,
      onSelected: onSortChanged,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sort,
            color: colors.onSurface,
            size: context.responsiveIconSize,
          ),
          SizedBox(width: context.responsiveHorizontalGapS),
          Text(
            sortLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: context.responsiveCaptionSize,
              color: colors.onSurface,
            ),
          ),
          SizedBox(width: context.responsiveHorizontalGapS / 2),
          Icon(
            Icons.arrow_drop_down,
            color: colors.onSurface,
            size: context.responsiveIconSize * 0.8,
          ),
        ],
      ),
      itemBuilder: (final context) => [
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.dateDesc,
          child: Row(
            children: [
              Icon(
                sortOrder == TodoSortOrder.dateDesc
                    ? Icons.check
                    : Icons.check_box_outline_blank,
                size: context.responsiveIconSize * 0.8,
                color: sortOrder == TodoSortOrder.dateDesc
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
              SizedBox(width: context.responsiveHorizontalGapS),
              Text(context.l10n.todoListSortDateDesc),
            ],
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.dateAsc,
          child: Row(
            children: [
              Icon(
                sortOrder == TodoSortOrder.dateAsc
                    ? Icons.check
                    : Icons.check_box_outline_blank,
                size: context.responsiveIconSize * 0.8,
                color: sortOrder == TodoSortOrder.dateAsc
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
              SizedBox(width: context.responsiveHorizontalGapS),
              Text(context.l10n.todoListSortDateAsc),
            ],
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.titleAsc,
          child: Row(
            children: [
              Icon(
                sortOrder == TodoSortOrder.titleAsc
                    ? Icons.check
                    : Icons.check_box_outline_blank,
                size: context.responsiveIconSize * 0.8,
                color: sortOrder == TodoSortOrder.titleAsc
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
              SizedBox(width: context.responsiveHorizontalGapS),
              Text(context.l10n.todoListSortTitleAsc),
            ],
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.titleDesc,
          child: Row(
            children: [
              Icon(
                sortOrder == TodoSortOrder.titleDesc
                    ? Icons.check
                    : Icons.check_box_outline_blank,
                size: context.responsiveIconSize * 0.8,
                color: sortOrder == TodoSortOrder.titleDesc
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
              SizedBox(width: context.responsiveHorizontalGapS),
              Text(context.l10n.todoListSortTitleDesc),
            ],
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.priorityDesc,
          child: Row(
            children: [
              Icon(
                sortOrder == TodoSortOrder.priorityDesc
                    ? Icons.check
                    : Icons.check_box_outline_blank,
                size: context.responsiveIconSize * 0.8,
                color: sortOrder == TodoSortOrder.priorityDesc
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
              SizedBox(width: context.responsiveHorizontalGapS),
              Text(context.l10n.todoListSortPriorityDesc),
            ],
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.priorityAsc,
          child: Row(
            children: [
              Icon(
                sortOrder == TodoSortOrder.priorityAsc
                    ? Icons.check
                    : Icons.check_box_outline_blank,
                size: context.responsiveIconSize * 0.8,
                color: sortOrder == TodoSortOrder.priorityAsc
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
              SizedBox(width: context.responsiveHorizontalGapS),
              Text(context.l10n.todoListSortPriorityAsc),
            ],
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.dueDateAsc,
          child: Row(
            children: [
              Icon(
                sortOrder == TodoSortOrder.dueDateAsc
                    ? Icons.check
                    : Icons.check_box_outline_blank,
                size: context.responsiveIconSize * 0.8,
                color: sortOrder == TodoSortOrder.dueDateAsc
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
              SizedBox(width: context.responsiveHorizontalGapS),
              Text(context.l10n.todoListSortDueDateAsc),
            ],
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.dueDateDesc,
          child: Row(
            children: [
              Icon(
                sortOrder == TodoSortOrder.dueDateDesc
                    ? Icons.check
                    : Icons.check_box_outline_blank,
                size: context.responsiveIconSize * 0.8,
                color: sortOrder == TodoSortOrder.dueDateDesc
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
              SizedBox(width: context.responsiveHorizontalGapS),
              Text(context.l10n.todoListSortDueDateDesc),
            ],
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.manual,
          child: Row(
            children: [
              Icon(
                sortOrder == TodoSortOrder.manual
                    ? Icons.check
                    : Icons.check_box_outline_blank,
                size: context.responsiveIconSize * 0.8,
                color: sortOrder == TodoSortOrder.manual
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
              SizedBox(width: context.responsiveHorizontalGapS),
              Text(context.l10n.todoListSortManual),
            ],
          ),
        ),
      ],
    );
  }
}
