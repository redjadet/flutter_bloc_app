part of 'todo_list_page.dart';

Future<void> _handleAddTodo(final BuildContext context) async {
  final TodoEditorResult? result = await showTodoEditorDialog(context: context);
  if (result == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  unawaited(HapticFeedback.selectionClick());
  await context.cubit<TodoListCubit>().addTodo(
    title: result.title,
    description: result.description,
  );
}

Future<void> _handleEditTodo(
  final BuildContext context,
  final TodoItem item,
) async {
  final TodoEditorResult? result = await showTodoEditorDialog(
    context: context,
    existing: item,
  );
  if (result == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  await context.cubit<TodoListCubit>().updateTodo(
    item: item,
    title: result.title,
    description: result.description,
  );
}

Future<void> _handleDeleteTodo(
  final BuildContext context,
  final TodoItem item,
) async {
  final bool? shouldDelete = await showTodoDeleteConfirmDialog(
    context: context,
    title: item.title,
  );
  if (shouldDelete != true) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  await _handleDeleteWithUndo(context, item, context.cubit<TodoListCubit>());
}

Future<void> _handleDeleteWithUndo(
  final BuildContext context,
  final TodoItem item,
  final TodoListCubit cubit,
) async {
  await cubit.deleteTodo(item);
  if (!context.mounted) {
    return;
  }

  final TodoItem? lastDeleted = cubit.lastDeletedItem;
  if (lastDeleted != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.todoListDeleteUndone),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: context.l10n.todoListUndoAction,
          onPressed: () => cubit.undoDelete(),
        ),
      ),
    );
  }
}
