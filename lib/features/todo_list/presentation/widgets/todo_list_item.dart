import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
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
    super.key,
  });

  final TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final TextStyle? titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: context.responsiveBodySize,
      decoration: item.isCompleted ? TextDecoration.lineThrough : null,
      color: item.isCompleted ? colors.onSurfaceVariant : colors.onSurface,
    );
    final TextStyle? descriptionStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: context.responsiveCaptionSize,
      color: colors.onSurfaceVariant,
    );

    return Semantics(
      label: item.isCompleted ? '${item.title} - Completed' : item.title,
      value: item.description ?? '',
      button: true,
      child: CommonCard(
        color: colors.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.responsiveCardRadius),
        ),
        margin: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: context.responsiveGapXS),
              child: Checkbox.adaptive(
                value: item.isCompleted,
                onChanged: (_) => onToggle(),
              ),
            ),
            SizedBox(width: context.responsiveHorizontalGapS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: titleStyle),
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    SizedBox(height: context.responsiveGapXS),
                    Text(item.description!, style: descriptionStyle),
                  ],
                ],
              ),
            ),
            SizedBox(width: context.responsiveHorizontalGapS),
            Column(
              children: [
                Semantics(
                  label: 'Edit ${item.title}',
                  button: true,
                  child: PlatformAdaptive.textButton(
                    context: context,
                    onPressed: onEdit,
                    child: Icon(
                      Icons.edit_outlined,
                      color: colors.primary,
                      size: context.responsiveIconSize,
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
                      size: context.responsiveIconSize,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
