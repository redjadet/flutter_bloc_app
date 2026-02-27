import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_priority_badge.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

Widget buildTodoItemContent({
  required final BuildContext context,
  required final TodoItem item,
  required final bool isCompactLayout,
  required final bool isCompactHeight,
  required final bool isPhoneLandscape,
  required final TextStyle? titleStyle,
  required final TextStyle? descriptionStyle,
  required final DateTime? dueDateLocal,
}) {
  final int titleMaxLines = isCompactHeight ? 1 : 2;
  final int descriptionMaxLines = isCompactHeight ? 1 : 2;
  final double verticalGap = isPhoneLandscape
      ? context.responsiveGapXS / 4
      : (isCompactHeight
            ? context.responsiveGapXS / 3
            : context.responsiveGapXS / 2);
  final double dueDateIconScale = isPhoneLandscape
      ? 0.5
      : (isCompactHeight ? 0.6 : 0.7);
  final bool showDescription = !isPhoneLandscape;
  final double dueDateFontScale = isPhoneLandscape ? 0.9 : 1;
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
        if (d.isNotEmpty && showDescription) ...[
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
