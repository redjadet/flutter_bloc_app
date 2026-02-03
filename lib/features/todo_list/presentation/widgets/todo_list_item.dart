import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_item_actions.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_item_content.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_item_dismissible.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';

class TodoListItem extends StatelessWidget {
  const TodoListItem({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    this.onToggle,
    this.onDeleteWithoutConfirmation,
    this.showDragHandle = false,
    this.isSelected = false,
    this.onSelectionChanged,
    super.key,
  });

  final TodoItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onToggle;
  final VoidCallback? onDeleteWithoutConfirmation;
  final bool showDragHandle;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;

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
    final DateTime? dueDateLocal = item.dueDate?.toLocal();

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
      child: LayoutBuilder(
        builder: (final context, final constraints) {
          final bool isCompactLayout = constraints.maxWidth < 340;

          final Widget actions = buildTodoItemActions(
            context: context,
            item: item,
            isCompactLayout: isCompactLayout,
            onEdit: onEdit,
            onDelete: onDelete,
          );

          return Row(
            children: [
              if (onSelectionChanged != null) ...[
                Checkbox.adaptive(
                  value: isSelected,
                  onChanged: (final value) {
                    if (value != null) {
                      onSelectionChanged!(value);
                    }
                  },
                  visualDensity: VisualDensity.compact,
                ),
                SizedBox(width: context.responsiveHorizontalGapS),
              ],
              if (showDragHandle) ...[
                Icon(
                  Icons.drag_handle,
                  color: colors.onSurfaceVariant,
                  size: context.responsiveIconSize * 0.9,
                ),
                SizedBox(width: context.responsiveHorizontalGapS),
              ],
              Expanded(
                child: buildTodoItemContent(
                  context: context,
                  item: item,
                  isCompactLayout: isCompactLayout,
                  titleStyle: titleStyle,
                  descriptionStyle: descriptionStyle,
                  dueDateLocal: dueDateLocal,
                ),
              ),
              SizedBox(width: context.responsiveHorizontalGapS),
              actions,
            ],
          );
        },
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

    return buildTodoItemDismissible(
      context: context,
      item: item,
      child: cardContent,
      onToggle: onToggle,
      onDelete: onDelete,
      onDeleteWithoutConfirmation: onDeleteWithoutConfirmation,
    );
  }
}
