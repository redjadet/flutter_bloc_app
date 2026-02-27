import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_item_density.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_priority_badge.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

Widget buildTodoItemContent({
  required final BuildContext context,
  required final TodoItem item,
  required final bool isCompactLayout,
  required final TodoItemDensity density,
  required final TextStyle? titleStyle,
  required final TextStyle? descriptionStyle,
  required final DateTime? dueDateLocal,
}) {
  final int titleMaxLines = density.isCompact ? 1 : 2;
  final int descriptionMaxLines = density.isCompact ? 1 : 2;
  final double verticalGap =
      context.responsiveGapXS /
      density.resolve(
        regular: 2,
        compact: 3,
        phoneLandscape: 4,
      );
  final double dueDateIconScale = density.resolve(
    regular: 0.7,
    compact: 0.6,
    phoneLandscape: 0.5,
  );
  final double dueDateFontScale = density.resolve(
    regular: 1,
    compact: 1,
    phoneLandscape: 0.9,
  );
  final double dueDateFontSize =
      (descriptionStyle?.fontSize ?? context.responsiveCaptionSize) *
      dueDateFontScale;

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (isCompactLayout && item.priority != TodoPriority.none) ...[
        Text(
          item.title,
          style: titleStyle,
          maxLines: titleMaxLines,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: verticalGap),
        TodoPriorityBadge(priority: item.priority),
      ] else
        Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: titleStyle,
                maxLines: titleMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (item.priority != TodoPriority.none) ...[
              SizedBox(width: context.responsiveHorizontalGapS),
              TodoPriorityBadge(priority: item.priority),
            ],
          ],
        ),
      if (item.description case final d?) ...[
        if (d.isNotEmpty && density.showsDescription) ...[
          SizedBox(height: verticalGap),
          Text(
            d,
            style: descriptionStyle,
            maxLines: descriptionMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
      if (dueDateLocal case final dueDate?) ...[
        SizedBox(height: verticalGap),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: context.responsiveIconSize * dueDateIconScale,
              color: item.isOverdue
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: context.responsiveHorizontalGapS / 2),
            Flexible(
              child: Text(
                '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
                style: descriptionStyle?.copyWith(
                  fontSize: dueDateFontSize,
                  color: item.isOverdue
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    ],
  );
}
