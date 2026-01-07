import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/helpers/todo_list_dialog_content.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

export 'todo_list_delete_dialogs.dart';

class TodoEditorResult {
  const TodoEditorResult({
    required this.title,
    required this.description,
    this.dueDate,
    this.priority = TodoPriority.none,
    this.isCompleted = false,
  });

  final String title;
  final String description;
  final DateTime? dueDate;
  final TodoPriority priority;
  final bool isCompleted;
}

Future<TodoEditorResult?> showTodoEditorDialog({
  required final BuildContext context,
  final TodoItem? existing,
}) async {
  final l10n = context.l10n;
  final TextEditingController titleController = TextEditingController(
    text: existing?.title ?? '',
  );
  final TextEditingController descriptionController = TextEditingController(
    text: existing?.description ?? '',
  );
  DateTime? selectedDueDate = existing?.dueDate?.toLocal();
  TodoPriority selectedPriority = existing?.priority ?? TodoPriority.none;
  bool isCompleted = existing?.isCompleted ?? false;

  final bool isCupertino = PlatformAdaptive.isCupertino(context);

  final TodoEditorResult? result = await showAdaptiveDialog<TodoEditorResult>(
    context: context,
    builder: (final context) => StatefulBuilder(
      builder: (final context, final setState) {
        final String trimmedTitle = titleController.text.trim();
        final bool canSave = trimmedTitle.isNotEmpty;

        final Widget content = buildTodoEditorDialogContent(
          context: context,
          titleController: titleController,
          descriptionController: descriptionController,
          isCupertino: isCupertino,
          selectedDueDate: selectedDueDate,
          selectedPriority: selectedPriority,
          isCompleted: isCompleted,
          onDueDateChanged: (final DateTime? date) {
            setState(() {
              selectedDueDate = date;
            });
          },
          onPriorityChanged: (final TodoPriority priority) {
            setState(() {
              selectedPriority = priority;
            });
          },
          onCompletedChanged: (final bool completed) {
            setState(() {
              isCompleted = completed;
            });
          },
        );

        return isCupertino
            ? CupertinoAlertDialog(
                title: Text(
                  existing == null
                      ? l10n.todoListAddDialogTitle
                      : l10n.todoListEditDialogTitle,
                ),
                content: Padding(
                  padding: EdgeInsets.only(top: context.responsiveGapS),
                  child: content,
                ),
                actions: [
                  PlatformAdaptive.dialogAction(
                    context: context,
                    onPressed: () => Navigator.of(context).pop(),
                    label: l10n.todoListCancelAction,
                  ),
                  PlatformAdaptive.dialogAction(
                    context: context,
                    onPressed: canSave
                        ? () => Navigator.of(context).pop(
                            TodoEditorResult(
                              title: trimmedTitle,
                              description: descriptionController.text.trim(),
                              dueDate: selectedDueDate,
                              priority: selectedPriority,
                              isCompleted: isCompleted,
                            ),
                          )
                        : null,
                    label: l10n.todoListSaveAction,
                  ),
                ],
              )
            : AlertDialog(
                title: Text(
                  existing == null
                      ? l10n.todoListAddDialogTitle
                      : l10n.todoListEditDialogTitle,
                ),
                content: content,
                actions: [
                  PlatformAdaptive.dialogAction(
                    context: context,
                    onPressed: () => Navigator.of(context).pop(),
                    label: l10n.todoListCancelAction,
                  ),
                  PlatformAdaptive.dialogAction(
                    context: context,
                    onPressed: canSave
                        ? () => Navigator.of(context).pop(
                            TodoEditorResult(
                              title: trimmedTitle,
                              description: descriptionController.text.trim(),
                              dueDate: selectedDueDate,
                              priority: selectedPriority,
                              isCompleted: isCompleted,
                            ),
                          )
                        : null,
                    label: l10n.todoListSaveAction,
                  ),
                ],
              );
      },
    ),
  );

  titleController.dispose();
  descriptionController.dispose();

  return result;
}
