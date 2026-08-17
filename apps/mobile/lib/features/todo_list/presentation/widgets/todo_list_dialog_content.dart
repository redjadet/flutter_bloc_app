import 'package:design_system/responsive.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_dialog_due_date.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_dialog_fields.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the content widget for the todo editor dialog.
Widget buildTodoEditorDialogContent({
  required BuildContext context,
  required TextEditingController titleController,
  required TextEditingController descriptionController,
  required bool isCupertino,
  required DateTime? selectedDueDate,
  required TodoPriority selectedPriority,
  required bool isCompleted,
  required ValueChanged<String> onTitleChanged,
  required ValueChanged<String> onDescriptionChanged,
  required ValueChanged<DateTime?> onDueDateChanged,
  required ValueChanged<TodoPriority> onPriorityChanged,
  required ValueChanged<bool> onCompletedChanged,
  FocusNode? titleFocusNode,
  FocusNode? descriptionFocusNode,
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
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTodoTextField(
            context: context,
            controller: titleController,
            focusNode: titleFocusNode,
            placeholder: l10n.todoListTitlePlaceholder,
            isCupertino: isCupertino,
            onChanged: onTitleChanged,
            autofocus: true,
          ),
          SizedBox(height: context.responsiveGapS),
          buildTodoTextField(
            context: context,
            controller: descriptionController,
            focusNode: descriptionFocusNode,
            placeholder: l10n.todoListDescriptionPlaceholder,
            isCupertino: isCupertino,
            onChanged: onDescriptionChanged,
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
          SizedBox(height: context.responsiveGapS),
          buildTodoCompletionCheckbox(
            context: context,
            isCompleted: isCompleted,
            onCompletedChanged: onCompletedChanged,
            isCupertino: isCupertino,
          ),
        ],
      ),
    ),
  );
}
