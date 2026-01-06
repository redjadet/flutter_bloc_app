import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/helpers/todo_list_dialog_due_date.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/helpers/todo_list_dialog_fields.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Builds the content widget for the todo editor dialog.
Widget buildTodoEditorDialogContent({
  required final BuildContext context,
  required final TextEditingController titleController,
  required final TextEditingController descriptionController,
  required final bool isCupertino,
  required final DateTime? selectedDueDate,
  required final TodoPriority selectedPriority,
  required final ValueChanged<DateTime?> onDueDateChanged,
  required final ValueChanged<TodoPriority> onPriorityChanged,
}) {
  final l10n = context.l10n;

  return ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: context.isDesktop
          ? 500
          : context.isTabletOrLarger
          ? 400
          : double.infinity,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTodoTextField(
          context: context,
          controller: titleController,
          placeholder: l10n.todoListTitlePlaceholder,
          isCupertino: isCupertino,
        ),
        SizedBox(height: context.responsiveGapS),
        buildTodoTextField(
          context: context,
          controller: descriptionController,
          placeholder: l10n.todoListDescriptionPlaceholder,
          isCupertino: isCupertino,
          maxLines: context.isDesktop
              ? 4
              : context.isTabletOrLarger
              ? 3
              : 3,
        ),
        SizedBox(height: context.responsiveGapS),
        buildTodoDueDatePicker(
          context: context,
          isCupertino: isCupertino,
          selectedDueDate: selectedDueDate,
          onDueDateChanged: onDueDateChanged,
        ),
        SizedBox(height: context.responsiveGapS),
        buildTodoPrioritySelector(
          context: context,
          selectedPriority: selectedPriority,
          onPriorityChanged: onPriorityChanged,
        ),
      ],
    ),
  );
}
