part of 'todo_list_page.dart';

/// Builds the app bar action widgets (select all, batch menu) for the todo list.
List<Widget>? _buildTodoListAppBarActions(
  final BuildContext context,
  final _TodoAppBarData barData,
) {
  final List<Widget> actionWidgets = <Widget>[];
  if (barData.hasFilteredItems) {
    actionWidgets.add(
      IconButton(
        icon: Icon(
          barData.allFilteredSelected ? Icons.deselect : Icons.select_all,
        ),
        tooltip: barData.allFilteredSelected
            ? context.l10n.todoListClearSelection
            : context.l10n.todoListSelectAll,
        onPressed: () {
          final cubit = context.cubit<TodoListCubit>();
          if (barData.allFilteredSelected) {
            cubit.clearSelection();
          } else {
            cubit.selectAllItems();
          }
        },
      ),
    );
  }
  if (barData.hasSelection) {
    actionWidgets.add(
      PopupMenuButton<_BatchMenuAction>(
        icon: const Icon(Icons.more_vert),
        tooltip: context.l10n.todoListItemsSelected(
          barData.selectedCount,
        ),
        onSelected: (final action) async {
          final cubit = context.cubit<TodoListCubit>();
          switch (action) {
            case _BatchMenuAction.complete:
              await cubit.batchCompleteSelected();
              break;
            case _BatchMenuAction.uncomplete:
              await cubit.batchUncompleteSelected();
              break;
            case _BatchMenuAction.delete:
              final bool? shouldDelete = await showTodoBatchDeleteConfirmDialog(
                context: context,
                count: barData.selectedCount,
              );
              if ((shouldDelete ?? false) && context.mounted) {
                await cubit.batchDeleteSelected();
              }
              break;
          }
        },
        itemBuilder: (final context) => <PopupMenuEntry<_BatchMenuAction>>[
          if (barData.hasSelectedActive)
            PopupMenuItem<_BatchMenuAction>(
              value: _BatchMenuAction.complete,
              child: Text(context.l10n.todoListBatchComplete),
            ),
          if (barData.hasSelectedCompleted)
            PopupMenuItem<_BatchMenuAction>(
              value: _BatchMenuAction.uncomplete,
              child: Text(context.l10n.todoListBatchUncomplete),
            ),
          PopupMenuItem<_BatchMenuAction>(
            value: _BatchMenuAction.delete,
            child: Text(
              context.l10n.todoListBatchDelete,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
  return actionWidgets.isEmpty ? null : actionWidgets;
}
