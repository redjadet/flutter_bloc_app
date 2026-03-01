part of 'todo_list_page.dart';

Future<void> _handleClearCompleted(
  final BuildContext context,
  final List<TodoItem> items,
  final TodoListCubit cubit,
) async {
  final int completedCount = items
      .where((final item) => item.isCompleted)
      .length;
  final bool? shouldClear = await showTodoClearCompletedConfirmDialog(
    context: context,
    count: completedCount,
  );
  if ((shouldClear ?? false) && context.mounted) {
    await cubit.clearCompleted();
  }
}

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
    dueDate: result.dueDate,
    priority: result.priority,
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
    dueDate: result.dueDate,
    priority: result.priority,
    isCompleted: result.isCompleted,
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
  if (lastDeleted != null && context.mounted) {
    final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
    snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.todoListDeleteUndone),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: context.l10n.todoListUndoAction,
          onPressed: () => cubit.undoDelete(),
        ),
      ),
    );
    // Keep timeout deterministic even when platforms/a11y prevent action
    // snackbars from auto-timing out. Guard with mounted to avoid calling
    // close() after the route is disposed.
    unawaited(
      Future<void>.delayed(
        const Duration(seconds: 2),
        () {
          if (context.mounted) {
            snackBarController.close();
          }
        },
      ),
    );
  }
}
