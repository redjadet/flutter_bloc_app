import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:material_ui/material_ui.dart';

/// Builds a platform-adaptive text field for the todo editor dialog.
Widget buildTodoTextField({
  required BuildContext context,
  required TextEditingController controller,
  required String placeholder,
  required bool isCupertino,
  ValueChanged<String>? onChanged,
  bool autofocus = false,
  int maxLines = 1,
  FocusNode? focusNode,
}) {
  final textField = PlatformAdaptive.textField(
    context: context,
    controller: controller,
    focusNode: focusNode,
    placeholder: placeholder,
    hintText: placeholder,
    onChanged: onChanged,
    autofocus: autofocus,
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
  required BuildContext context,
  required TodoPriority selectedPriority,
  required ValueChanged<TodoPriority> onPriorityChanged,
}) {
  final l10n = context.l10n;

  return CommonDropdownField<TodoPriority>(
    value: selectedPriority,
    items: TodoPriority.values
        .map((priority) {
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
        })
        .toList(growable: false),
    onChanged: (value) {
      if (value != null) {
        onPriorityChanged(value);
      }
    },
    labelText: l10n.todoListPriorityLabel,
  );
}

/// Builds a completion checkbox for the todo editor dialog.
Widget buildTodoCompletionCheckbox({
  required BuildContext context,
  required bool isCompleted,
  required ValueChanged<bool> onCompletedChanged,
  required bool isCupertino,
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
            onChanged: (value) {
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
      onChanged: (value) {
        if (value != null) {
          onCompletedChanged(value);
        }
      },
      contentPadding: EdgeInsets.zero,
      dense: true,
    ),
  );
}
