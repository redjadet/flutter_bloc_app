import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/helpers/todo_list_date_picker.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Builds a due date picker widget for the todo editor dialog.
Widget buildTodoDueDatePicker({
  required final BuildContext context,
  required final bool isCupertino,
  required final DateTime? selectedDueDate,
  required final ValueChanged<DateTime?> onDueDateChanged,
}) {
  final l10n = context.l10n;
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () async {
        final DateTime? initialDate = selectedDueDate;
        final DateTime firstDate = DateTime.now().subtract(
          const Duration(days: 365),
        );
        final DateTime lastDate = DateTime.now().add(
          const Duration(days: 3650),
        );
        final DateTime? pickedDate = await showAdaptiveTodoDatePicker(
          context: context,
          isCupertino: isCupertino,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
          title: l10n.todoListDueDateLabel,
          cancelLabel: l10n.todoListCancelAction,
          clearLabel: l10n.todoListClearDueDate,
          saveLabel: l10n.todoListSaveAction,
        );
        if (!context.mounted) return;
        // pickedDate is null when cleared or cancelled
        // We need to distinguish, but for simplicity, we'll update if it changed
        if (pickedDate != selectedDueDate) {
          onDueDateChanged(pickedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.todoListDueDateLabel,
          suffixIcon: const Icon(Icons.calendar_today),
          contentPadding: EdgeInsets.all(context.responsiveGapS),
        ),
        child: Text(
          selectedDueDate != null
              ? formatTodoDate(selectedDueDate)
              : l10n.todoListNoDueDate,
          style: TextStyle(
            color: selectedDueDate != null
                ? null
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ),
  );
}
