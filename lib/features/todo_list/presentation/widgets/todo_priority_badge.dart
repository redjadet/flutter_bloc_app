import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class TodoPriorityBadge extends StatelessWidget {
  const TodoPriorityBadge({required this.priority, super.key});

  final TodoPriority priority;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    final String label = switch (priority) {
      TodoPriority.none => '',
      TodoPriority.low => l10n.todoListPriorityLow,
      TodoPriority.medium => l10n.todoListPriorityMedium,
      TodoPriority.high => l10n.todoListPriorityHigh,
    };

    final Color badgeColor = switch (priority) {
      TodoPriority.none => colors.surfaceContainerHighest,
      TodoPriority.low => colors.tertiary,
      TodoPriority.medium => colors.secondary,
      TodoPriority.high => colors.error,
    };

    if (priority == TodoPriority.none) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveHorizontalGapS,
        vertical: context.responsiveGapXS / 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(context.responsiveCardRadius / 2),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: badgeColor,
          fontSize: context.responsiveCaptionSize * 0.9,
        ),
      ),
    );
  }
}
