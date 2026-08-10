part of 'todo_list_page.dart';

@immutable
class _TodoHeaderLayout {
  const _TodoHeaderLayout({
    required this.gapM,
    required this.gapS,
    required this.showCompactHeader,
    required this.showStats,
    required this.showSearch,
    required this.showFilterBar,
    required this.showSecondaryControls,
    required this.showBatchActions,
    required this.showAddButton,
  });

  factory _TodoHeaderLayout.resolve({
    required final BuildContext context,
    required final TodoListListProjection listData,
    required final List<TodoItem> filteredItems,
    required final double availableHeight,
  }) {
    // Window height (not layout height) so keyboard insets do not steal focus.
    final bool isSpaceLimited = MediaQuery.sizeOf(context).height < 600;
    final bool isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final double gapM = isSpaceLimited
        ? context.responsiveGapS
        : context.responsiveGapM;
    final double gapS = isSpaceLimited
        ? context.responsiveGapXS
        : context.responsiveGapS;
    final bool showCompactHeader = isSpaceLimited || isKeyboardVisible;
    final bool showStats =
        !showCompactHeader &&
        !isKeyboardVisible &&
        availableHeight >= statsMinHeight;
    final bool shouldKeepSearchVisible =
        isKeyboardVisible || listData.searchQuery.isNotEmpty;
    final bool showSearch =
        listData.items.isNotEmpty &&
        (isSpaceLimited ||
            availableHeight >= searchMinHeight ||
            shouldKeepSearchVisible);
    final bool showFilterBar =
        !isKeyboardVisible && availableHeight >= filterMinHeight;
    final bool showSecondaryControls =
        showFilterBar &&
        listData.items.isNotEmpty &&
        !showCompactHeader &&
        availableHeight >= secondaryControlsMinHeight;
    final bool showBatchActions =
        showSecondaryControls && availableHeight >= batchActionsMinHeight;
    final bool showAddButton =
        showBatchActions &&
        filteredItems.isNotEmpty &&
        availableHeight >= addButtonMinHeight;

    return _TodoHeaderLayout(
      gapM: gapM,
      gapS: gapS,
      showCompactHeader: showCompactHeader,
      showStats: showStats,
      showSearch: showSearch,
      showFilterBar: showFilterBar,
      showSecondaryControls: showSecondaryControls,
      showBatchActions: showBatchActions,
      showAddButton: showAddButton,
    );
  }

  final double gapM;
  final double gapS;
  final bool showCompactHeader;
  final bool showStats;
  final bool showSearch;
  final bool showFilterBar;
  final bool showSecondaryControls;
  final bool showBatchActions;
  final bool showAddButton;

  static const double statsMinHeight = 560;
  static const double searchMinHeight = 120;
  static const double filterMinHeight = 420;
  static const double secondaryControlsMinHeight = 500;
  static const double batchActionsMinHeight = 560;
  static const double addButtonMinHeight = 620;
}

Widget _todoListPane({
  required final BuildContext context,
  required final _TodoHeaderLayout layout,
  required final TodoListListProjection listData,
  required final List<TodoItem> filteredItems,
  required final TodoListCubit cubit,
  required final ScrollController scrollController,
  required final bool padTop,
}) => Expanded(
  child: Padding(
    padding: EdgeInsets.only(top: padTop ? layout.gapS : 0),
    child: TodoListContent(
      filteredItems: filteredItems,
      sortOrder: listData.sortOrder,
      scrollController: scrollController,
      cubit: cubit,
      onItemSelectionChanged: (final itemId, {required final selected}) {
        cubit.toggleItemSelection(itemId);
      },
      onAddTodo: () => _handleAddTodo(context),
      onEditTodo: (final item) => _handleEditTodo(context, item),
      onDeleteTodo: (final item) => _handleDeleteTodo(context, item),
      onDeleteWithUndo: (final item, final cubit) =>
          _handleDeleteWithUndo(context, item, cubit),
    ),
  ),
);
