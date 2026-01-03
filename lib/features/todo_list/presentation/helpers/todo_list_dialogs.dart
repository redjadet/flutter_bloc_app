import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class TodoEditorResult {
  const TodoEditorResult({required this.title, required this.description});

  final String title;
  final String description;
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

  final bool isCupertino = PlatformAdaptive.isCupertino(context);

  final TodoEditorResult? result = await showAdaptiveDialog<TodoEditorResult>(
    context: context,
    builder: (final context) => StatefulBuilder(
      builder: (final context, final setState) {
        final String trimmedTitle = titleController.text.trim();
        final bool canSave = trimmedTitle.isNotEmpty;

        Widget buildTextField({
          required final TextEditingController controller,
          required final String placeholder,
          final int maxLines = 1,
        }) {
          if (isCupertino) {
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: context.responsiveGapXS,
              ),
              child: CupertinoTextField(
                controller: controller,
                placeholder: placeholder,
                maxLines: maxLines,
                padding: EdgeInsets.all(context.responsiveGapS),
                onChanged: (_) => setState(() {}),
              ),
            );
          }
          return TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: placeholder,
              contentPadding: EdgeInsets.all(context.responsiveGapS),
            ),
            maxLines: maxLines,
            onChanged: (_) => setState(() {}),
          );
        }

        final Widget content = ConstrainedBox(
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
              buildTextField(
                controller: titleController,
                placeholder: l10n.todoListTitlePlaceholder,
              ),
              SizedBox(height: context.responsiveGapS),
              buildTextField(
                controller: descriptionController,
                placeholder: l10n.todoListDescriptionPlaceholder,
                maxLines: context.isDesktop
                    ? 4
                    : context.isTabletOrLarger
                    ? 3
                    : 3,
              ),
            ],
          ),
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

Future<bool?> showTodoDeleteConfirmDialog({
  required final BuildContext context,
  required final String title,
}) async {
  final l10n = context.l10n;
  final bool isCupertino = PlatformAdaptive.isCupertino(context);
  return showAdaptiveDialog<bool>(
    context: context,
    builder: (final context) => isCupertino
        ? CupertinoAlertDialog(
            title: Text(l10n.todoListDeleteDialogTitle),
            content: Padding(
              padding: EdgeInsets.only(top: context.responsiveGapS),
              child: Text(
                l10n.todoListDeleteDialogMessage(title),
              ),
            ),
            actions: [
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: () => Navigator.of(context).pop(false),
                label: l10n.todoListCancelAction,
              ),
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: () => Navigator.of(context).pop(true),
                label: l10n.todoListDeleteAction,
                isDestructive: true,
              ),
            ],
          )
        : AlertDialog(
            title: Text(l10n.todoListDeleteDialogTitle),
            content: Text(
              l10n.todoListDeleteDialogMessage(title),
            ),
            actions: [
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: () => Navigator.of(context).pop(false),
                label: l10n.todoListCancelAction,
              ),
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: () => Navigator.of(context).pop(true),
                label: l10n.todoListDeleteAction,
                isDestructive: true,
              ),
            ],
          ),
  );
}
