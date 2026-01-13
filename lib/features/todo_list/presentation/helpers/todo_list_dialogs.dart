import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/helpers/todo_list_dialog_content.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
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
}) async => showAdaptiveDialog<TodoEditorResult>(
  context: context,
  builder: (final context) => _TodoEditorDialog(existing: existing),
);

class _TodoEditorDialog extends StatefulWidget {
  const _TodoEditorDialog({required this.existing});

  final TodoItem? existing;

  @override
  State<_TodoEditorDialog> createState() => _TodoEditorDialogState();
}

class _TodoEditorDialogState extends State<_TodoEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime? _selectedDueDate;
  late TodoPriority _selectedPriority;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existing?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existing?.description ?? '',
    );
    _selectedDueDate = widget.existing?.dueDate?.toLocal();
    _selectedPriority = widget.existing?.priority ?? TodoPriority.none;
    _isCompleted = widget.existing?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final bool isCupertino = PlatformAdaptive.isCupertino(context);
    final String trimmedTitle = _titleController.text.trim();
    final bool canSave = trimmedTitle.isNotEmpty;

    final Widget content = buildTodoEditorDialogContent(
      context: context,
      titleController: _titleController,
      descriptionController: _descriptionController,
      isCupertino: isCupertino,
      selectedDueDate: _selectedDueDate,
      selectedPriority: _selectedPriority,
      isCompleted: _isCompleted,
      onDueDateChanged: (final DateTime? date) {
        setState(() {
          _selectedDueDate = date;
        });
      },
      onPriorityChanged: (final TodoPriority priority) {
        setState(() {
          _selectedPriority = priority;
        });
      },
      onCompletedChanged: (final bool completed) {
        setState(() {
          _isCompleted = completed;
        });
      },
    );

    return isCupertino
        ? CupertinoAlertDialog(
            title: Text(
              widget.existing == null
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
                onPressed: () => NavigationUtils.maybePop(context),
                label: l10n.todoListCancelAction,
              ),
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: canSave
                    ? () => NavigationUtils.maybePop(
                        context,
                        result: TodoEditorResult(
                          title: _titleController.text.trim(),
                          description: _descriptionController.text.trim(),
                          dueDate: _selectedDueDate,
                          priority: _selectedPriority,
                          isCompleted: _isCompleted,
                        ),
                      )
                    : null,
                label: l10n.todoListSaveAction,
              ),
            ],
          )
        : AlertDialog(
            title: Text(
              widget.existing == null
                  ? l10n.todoListAddDialogTitle
                  : l10n.todoListEditDialogTitle,
            ),
            content: content,
            actions: [
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: () => NavigationUtils.maybePop(context),
                label: l10n.todoListCancelAction,
              ),
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: canSave
                    ? () => NavigationUtils.maybePop(
                        context,
                        result: TodoEditorResult(
                          title: _titleController.text.trim(),
                          description: _descriptionController.text.trim(),
                          dueDate: _selectedDueDate,
                          priority: _selectedPriority,
                          isCompleted: _isCompleted,
                        ),
                      )
                    : null,
                label: l10n.todoListSaveAction,
              ),
            ],
          );
  }
}
