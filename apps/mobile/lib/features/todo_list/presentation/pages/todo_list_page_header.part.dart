part of 'todo_list_page.dart';

List<Widget> _todoHeaderChildren({
  required final BuildContext context,
  required final _TodoHeaderLayout layout,
  required final TodoListListProjection listData,
  required final List<TodoItem> filteredItems,
  required final TodoListCubit cubit,
  required final ThemeData theme,
  required final ColorScheme colors,
}) => [
  Visibility(
    visible: layout.showStats,
    maintainState: true,
    child: const TodoStatsWidget(),
  ),
  if (layout.showSearch) ...[
    SizedBox(height: layout.showCompactHeader ? layout.gapS : layout.gapM),
    const TodoSearchField(key: ValueKey<String>('todo_search_field')),
  ],
  if (layout.showFilterBar) ...[
    SizedBox(height: layout.gapM),
    TodoFilterBar(
      filter: listData.filter,
      hasCompleted: listData.hasCompleted,
      onFilterChanged: cubit.setFilter,
      onClearCompleted: listData.hasCompleted
          ? () => _handleClearCompleted(context, listData.items, cubit)
          : null,
    ),
    if (layout.showSecondaryControls) ...[
      SizedBox(height: layout.gapS),
      Wrap(
        alignment: WrapAlignment.end,
        spacing: context.responsiveHorizontalGapS,
        runSpacing: context.responsiveGapXS,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (listData.hasCompleted)
            PlatformAdaptive.textButton(
              context: context,
              onPressed: () =>
                  _handleClearCompleted(context, listData.items, cubit),
              color: colors.error,
              child: Text(
                context.l10n.todoListClearCompletedAction,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: context.responsiveCaptionSize,
                  color: colors.error,
                ),
              ),
            ),
          TodoSortBar(
            sortOrder: listData.sortOrder,
            onSortChanged: cubit.setSortOrder,
          ),
        ],
      ),
      if (layout.showBatchActions) ...[
        SizedBox(height: layout.gapS),
        TypeSafeBlocSelector<
          TodoListCubit,
          TodoListState,
          TodoListSelectionData
        >(
          selector: TodoListSelectionData.fromState,
          builder: (final context, final selection) => TodoBatchActionsBar(
            items: listData.items,
            filteredItems: filteredItems,
            selectedItemIds: selection.selectedItemIds,
            hasSelection: selection.hasSelectedItems,
            cubit: cubit,
          ),
        ),
      ],
      if (layout.showAddButton) ...[
        SizedBox(height: layout.gapM),
        PlatformAdaptive.filledButton(
          context: context,
          onPressed: () => _handleAddTodo(context),
          child: Text(context.l10n.todoListAddAction),
        ),
      ],
    ],
  ],
];

Widget _todoHeaderShell({
  required final List<Widget> headerChildren,
  required final ScrollController scrollController,
}) {
  if (headerChildren.isEmpty) {
    return const SizedBox.shrink();
  }
  return Listener(
    onPointerSignal: (final event) {
      if (event is! PointerScrollEvent || !scrollController.hasClients) {
        return;
      }
      final position = scrollController.position;
      final double nextOffset = (scrollController.offset + event.scrollDelta.dy)
          .clamp(0.0, position.maxScrollExtent);
      scrollController.jumpTo(nextOffset);
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: headerChildren,
    ),
  );
}
