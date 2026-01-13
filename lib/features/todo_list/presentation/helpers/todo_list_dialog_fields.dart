import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

/// Builds a platform-adaptive text field for the todo editor dialog.
Widget buildTodoTextField({
  required final BuildContext context,
  required final TextEditingController controller,
  required final String placeholder,
  required final bool isCupertino,
  final int maxLines = 1,
}) {
  final textField = PlatformAdaptive.textField(
    context: context,
    controller: controller,
    placeholder: placeholder,
    hintText: placeholder,
    maxLines: maxLines,
    padding: isCupertino ? EdgeInsets.all(context.responsiveGapS) : null,
    decoration: isCupertino
        ? null
        : InputDecoration(
            hintText: placeholder,
            contentPadding: EdgeInsets.all(context.responsiveGapS),
          ),
  );

  if (isCupertino) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveGapXS,
      ),
      child: textField,
    );
  }
  return textField;
}

/// Builds a priority selector dropdown for the todo editor dialog.
Widget buildTodoPrioritySelector({
  required final BuildContext context,
  required final TodoPriority selectedPriority,
  required final ValueChanged<TodoPriority> onPriorityChanged,
}) {
  final l10n = context.l10n;
  final isCupertino = PlatformAdaptive.isCupertino(context);

  if (isCupertino) {
    final String selectedLabel = switch (selectedPriority) {
      TodoPriority.none => l10n.todoListPriorityNone,
      TodoPriority.low => l10n.todoListPriorityLow,
      TodoPriority.medium => l10n.todoListPriorityMedium,
      TodoPriority.high => l10n.todoListPriorityHigh,
    };

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveGapXS,
      ),
      child: GestureDetector(
        onTap: () async {
          final TodoPriority? result =
              await PlatformAdaptive.showPickerModal<TodoPriority>(
                context: context,
                items: TodoPriority.values,
                selectedItem: selectedPriority,
                itemLabel: (final priority) => switch (priority) {
                  TodoPriority.none => l10n.todoListPriorityNone,
                  TodoPriority.low => l10n.todoListPriorityLow,
                  TodoPriority.medium => l10n.todoListPriorityMedium,
                  TodoPriority.high => l10n.todoListPriorityHigh,
                },
                title: l10n.todoListPriorityLabel,
              );
          if (result != null && context.mounted) {
            onPriorityChanged(result);
          }
        },
        child: Container(
          padding: EdgeInsets.all(context.responsiveGapS),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(context.responsiveCardRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Icon(
                CupertinoIcons.chevron_down,
                size: 16,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  return Material(
    color: Colors.transparent,
    child: DropdownButtonFormField<TodoPriority>(
      initialValue: selectedPriority,
      decoration: InputDecoration(
        labelText: l10n.todoListPriorityLabel,
        contentPadding: EdgeInsets.all(context.responsiveGapS),
      ),
      items: TodoPriority.values.map((final priority) {
        final String label = switch (priority) {
          TodoPriority.none => l10n.todoListPriorityNone,
          TodoPriority.low => l10n.todoListPriorityLow,
          TodoPriority.medium => l10n.todoListPriorityMedium,
          TodoPriority.high => l10n.todoListPriorityHigh,
        };
        return DropdownMenuItem<TodoPriority>(
          value: priority,
          child: Text(label),
        );
      }).toList(),
      onChanged: (final TodoPriority? value) {
        if (value != null) {
          onPriorityChanged(value);
        }
      },
    ),
  );
}

/// Builds a completion checkbox for the todo editor dialog.
Widget buildTodoCompletionCheckbox({
  required final BuildContext context,
  required final bool isCompleted,
  required final ValueChanged<bool> onCompletedChanged,
  required final bool isCupertino,
}) {
  final l10n = context.l10n;

  if (isCupertino) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveGapXS,
      ),
      child: Row(
        children: [
          Checkbox.adaptive(
            value: isCompleted,
            onChanged: (final bool? value) {
              if (value != null) {
                onCompletedChanged(value);
              }
            },
          ),
          SizedBox(width: context.responsiveHorizontalGapS),
          Expanded(
            child: GestureDetector(
              onTap: () => onCompletedChanged(!isCompleted),
              child: Text(
                l10n.todoListCompleteAction,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  return Material(
    color: Colors.transparent,
    child: CheckboxListTile(
      title: Text(l10n.todoListCompleteAction),
      value: isCompleted,
      onChanged: (final bool? value) {
        if (value != null) {
          onCompletedChanged(value);
        }
      },
      contentPadding: EdgeInsets.zero,
      dense: true,
    ),
  );
}
