import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/icon_label_row.dart';

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
      child: IconLabelRow(
        icon: Icons.sort,
        label: sortLabel,
        iconColor: colors.onSurface,
        textStyle: theme.textTheme.labelLarge?.copyWith(
          fontSize: context.responsiveCaptionSize,
          color: colors.onSurface,
        ),
        trailing: Icon(
          Icons.arrow_drop_down,
          color: colors.onSurface,
          size: context.responsiveIconSize * 0.8,
        ),
      ),
      itemBuilder: (final context) => [
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.dateDesc,
          child: IconLabelRow(
            icon: sortOrder == TodoSortOrder.dateDesc
                ? Icons.check
                : Icons.check_box_outline_blank,
            label: context.l10n.todoListSortDateDesc,
            iconSize: context.responsiveIconSize * 0.8,
            iconColor: sortOrder == TodoSortOrder.dateDesc
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.dateAsc,
          child: IconLabelRow(
            icon: sortOrder == TodoSortOrder.dateAsc
                ? Icons.check
                : Icons.check_box_outline_blank,
            label: context.l10n.todoListSortDateAsc,
            iconSize: context.responsiveIconSize * 0.8,
            iconColor: sortOrder == TodoSortOrder.dateAsc
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.titleAsc,
          child: IconLabelRow(
            icon: sortOrder == TodoSortOrder.titleAsc
                ? Icons.check
                : Icons.check_box_outline_blank,
            label: context.l10n.todoListSortTitleAsc,
            iconSize: context.responsiveIconSize * 0.8,
            iconColor: sortOrder == TodoSortOrder.titleAsc
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.titleDesc,
          child: IconLabelRow(
            icon: sortOrder == TodoSortOrder.titleDesc
                ? Icons.check
                : Icons.check_box_outline_blank,
            label: context.l10n.todoListSortTitleDesc,
            iconSize: context.responsiveIconSize * 0.8,
            iconColor: sortOrder == TodoSortOrder.titleDesc
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.priorityDesc,
          child: IconLabelRow(
            icon: sortOrder == TodoSortOrder.priorityDesc
                ? Icons.check
                : Icons.check_box_outline_blank,
            label: context.l10n.todoListSortPriorityDesc,
            iconSize: context.responsiveIconSize * 0.8,
            iconColor: sortOrder == TodoSortOrder.priorityDesc
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.priorityAsc,
          child: IconLabelRow(
            icon: sortOrder == TodoSortOrder.priorityAsc
                ? Icons.check
                : Icons.check_box_outline_blank,
            label: context.l10n.todoListSortPriorityAsc,
            iconSize: context.responsiveIconSize * 0.8,
            iconColor: sortOrder == TodoSortOrder.priorityAsc
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.dueDateAsc,
          child: IconLabelRow(
            icon: sortOrder == TodoSortOrder.dueDateAsc
                ? Icons.check
                : Icons.check_box_outline_blank,
            label: context.l10n.todoListSortDueDateAsc,
            iconSize: context.responsiveIconSize * 0.8,
            iconColor: sortOrder == TodoSortOrder.dueDateAsc
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.dueDateDesc,
          child: IconLabelRow(
            icon: sortOrder == TodoSortOrder.dueDateDesc
                ? Icons.check
                : Icons.check_box_outline_blank,
            label: context.l10n.todoListSortDueDateDesc,
            iconSize: context.responsiveIconSize * 0.8,
            iconColor: sortOrder == TodoSortOrder.dueDateDesc
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
        PopupMenuItem<TodoSortOrder>(
          value: TodoSortOrder.manual,
          child: IconLabelRow(
            icon: sortOrder == TodoSortOrder.manual
                ? Icons.check
                : Icons.check_box_outline_blank,
            label: context.l10n.todoListSortManual,
            iconSize: context.responsiveIconSize * 0.8,
            iconColor: sortOrder == TodoSortOrder.manual
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
