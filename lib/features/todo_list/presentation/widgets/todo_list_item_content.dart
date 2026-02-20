import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_priority_badge.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

Widget buildTodoItemContent({
  required final BuildContext context,
  required final TodoItem item,
  required final bool isCompactLayout,
  required final TextStyle? titleStyle,
  required final TextStyle? descriptionStyle,
  required final DateTime? dueDateLocal,
}) => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    if (isCompactLayout && item.priority != TodoPriority.none) ...[
      Text(
        item.title,
        style: titleStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: context.responsiveGapXS / 2),
      TodoPriorityBadge(priority: item.priority),
    ] else
      Row(
        children: [
          Expanded(
            child: Text(
              item.title,
              style: titleStyle,
              maxLines: 2,
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
      if (d.isNotEmpty) ...[
        SizedBox(height: context.responsiveGapXS / 2),
        Text(
          d,
          style: descriptionStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ],
    if (dueDateLocal case final dueDate?) ...[
      SizedBox(height: context.responsiveGapXS / 2),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: context.responsiveIconSize * 0.7,
            color: item.isOverdue
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: context.responsiveHorizontalGapS / 2),
          Flexible(
            child: Text(
              '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
              style: descriptionStyle?.copyWith(
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
