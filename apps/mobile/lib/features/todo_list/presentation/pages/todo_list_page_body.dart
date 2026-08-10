part of 'todo_list_page.dart';

class _TodoListBody extends StatefulWidget {
  const _TodoListBody();

  @override
  State<_TodoListBody> createState() => _TodoListBodyState();
}

class _TodoListBodyState extends State<_TodoListBody> {
  late final ScrollController _listScrollController;

  @override
  void initState() {
    super.initState();
    _listScrollController = ScrollController();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    final BuildContext context,
  ) => ViewStatusSwitcher<TodoListCubit, TodoListState, TodoListLifecycleData>(
    selector: TodoListLifecycleData.fromState,
    isLoading: (final data) => data.isLoading,
    isError: (final data) => data.hasError,
    loadingBuilder: (final _) => const CommonLoadingWidget(),
    errorBuilder: (final context, final data) => CommonErrorView(
      message: data.errorMessage ?? context.l10n.todoListLoadError,
      onRetry: () => context.cubit<TodoListCubit>().loadInitial(),
    ),
    builder: (final context, final _) {
      return TypeSafeBlocSelector<
        TodoListCubit,
        TodoListState,
        TodoListListProjection
      >(
        selector: TodoListListProjection.fromState,
        builder: (final context, final listData) {
          final List<TodoItem> filteredItems = listData.filteredItems;
          final TodoListCubit cubit = context.cubit<TodoListCubit>();
          final ThemeData theme = Theme.of(context);
          final ColorScheme colors = theme.colorScheme;

          return CommonMaxWidth(
            maxWidth: context.contentMaxWidth,
            child: LayoutBuilder(
              builder: (final context, final constraints) {
                final _TodoHeaderLayout layout = _TodoHeaderLayout.resolve(
                  context: context,
                  listData: listData,
                  filteredItems: filteredItems,
                  availableHeight: constraints.maxHeight,
                );

                final List<Widget> headerChildren = [
                  Visibility(
                    visible: layout.showStats,
                    maintainState: true,
                    child: const TodoStatsWidget(),
                  ),
                  if (layout.showSearch) ...[
                    SizedBox(
                      height: layout.showCompactHeader
                          ? layout.gapS
                          : layout.gapM,
                    ),
                    const TodoSearchField(
                      key: ValueKey<String>('todo_search_field'),
                    ),
                  ],
                  if (layout.showFilterBar) ...[
                    SizedBox(height: layout.gapM),
                    TodoFilterBar(
                      filter: listData.filter,
                      hasCompleted: listData.hasCompleted,
                      onFilterChanged: cubit.setFilter,
                      onClearCompleted: listData.hasCompleted
                          ? () => _handleClearCompleted(
                              context,
                              listData.items,
                              cubit,
                            )
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
                              onPressed: () => _handleClearCompleted(
                                context,
                                listData.items,
                                cubit,
                              ),
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
                          builder: (final context, final selection) {
                            return TodoBatchActionsBar(
                              items: listData.items,
                              filteredItems: filteredItems,
                              selectedItemIds: selection.selectedItemIds,
                              hasSelection: selection.hasSelectedItems,
                              cubit: cubit,
                            );
                          },
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

                final Widget listContent = Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: headerChildren.isNotEmpty ? layout.gapS : 0,
                    ),
                    child:
                        TypeSafeBlocSelector<
                          TodoListCubit,
                          TodoListState,
                          TodoListSelectionData
                        >(
                          selector: TodoListSelectionData.fromState,
                          builder: (final context, final selection) {
                            return TodoListContent(
                              filteredItems: filteredItems,
                              sortOrder: listData.sortOrder,
                              selectedItemIds: selection.selectedItemIds,
                              scrollController: _listScrollController,
                              cubit: cubit,
                              onItemSelectionChanged:
                                  (final itemId, {required final selected}) {
                                    if (selected !=
                                        selection.selectedItemIds.contains(
                                          itemId,
                                        )) {
                                      cubit.toggleItemSelection(itemId);
                                    }
                                  },
                              onAddTodo: () => _handleAddTodo(context),
                              onEditTodo: (final item) =>
                                  _handleEditTodo(context, item),
                              onDeleteTodo: (final item) =>
                                  _handleDeleteTodo(context, item),
                              onDeleteWithUndo: (final item, final cubit) =>
                                  _handleDeleteWithUndo(context, item, cubit),
                            );
                          },
                        ),
                  ),
                );

                final Widget header = headerChildren.isEmpty
                    ? const SizedBox.shrink()
                    : Listener(
                        onPointerSignal: (final event) {
                          if (event is! PointerScrollEvent) {
                            return;
                          }
                          if (!_listScrollController.hasClients) {
                            return;
                          }
                          final position = _listScrollController.position;
                          final double nextOffset =
                              (_listScrollController.offset +
                                      event.scrollDelta.dy)
                                  .clamp(0.0, position.maxScrollExtent);
                          _listScrollController.jumpTo(nextOffset);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: headerChildren,
                        ),
                      );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [header, listContent],
                );
              },
            ),
          );
        },
      );
    },
  );
}
