import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/helpers/todo_list_dialogs.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/pages/todo_list_page_data.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_batch_actions_bar.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_filter_bar.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_content.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_search_field.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_sort_bar.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_stats_widget.dart';
// import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_sync_banner.dart'; // Hidden per user request
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:flutter_bloc_app/shared/widgets/common_max_width.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

part 'todo_list_page_handlers.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.todoListTitle,
      body: const _TodoListBody(),
    );
  }
}

class _TodoListBody extends StatelessWidget {
  const _TodoListBody();

  @override
  Widget build(
    final BuildContext context,
  ) => TypeSafeBlocSelector<TodoListCubit, TodoListState, TodoListViewData>(
    selector: (final state) => TodoListViewData(
      isLoading: state.isLoading,
      hasError: state.hasError,
      errorMessage: state.errorMessage,
      items: state.items,
      filteredItems: state.filteredItems,
      filter: state.filter,
      hasCompleted: state.hasCompleted,
      searchQuery: state.searchQuery,
      sortOrder: state.sortOrder,
      selectedItemIds: state.selectedItemIds,
      hasSelectedItems: state.hasSelectedItems,
      selectedCount: state.selectedCount,
    ),
    builder: (final context, final data) {
      if (data.isLoading) {
        return const CommonLoadingWidget();
      }
      if (data.hasError) {
        return CommonErrorView(
          message: data.errorMessage ?? context.l10n.todoListLoadError,
          onRetry: () => context.cubit<TodoListCubit>().loadInitial(),
        );
      }

      final TodoListCubit cubit = context.cubit<TodoListCubit>();
      final ThemeData theme = Theme.of(context);
      final ColorScheme colors = theme.colorScheme;

      return CommonMaxWidth(
        maxWidth: context.contentMaxWidth,
        child: LayoutBuilder(
          builder: (final context, final constraints) {
            final _TodoHeaderLayout layout = _TodoHeaderLayout.resolve(
              context: context,
              data: data,
              availableHeight: constraints.maxHeight,
            );

            final List<Widget> headerChildren = [
              // Sync banner hidden on purpose
              // const TodoSyncBanner(),
              Visibility(
                visible: layout.showStats,
                maintainState: true,
                child: const TodoStatsWidget(),
              ),
              if (layout.showSearch) ...[
                SizedBox(
                  height: layout.showCompactHeader ? layout.gapS : layout.gapM,
                ),
                const TodoSearchField(
                  key: ValueKey<String>('todo_search_field'),
                ),
              ],
              if (layout.showFilterBar) ...[
                SizedBox(height: layout.gapM),
                TodoFilterBar(
                  filter: data.filter,
                  hasCompleted: data.hasCompleted,
                  onFilterChanged: cubit.setFilter,
                  onClearCompleted: data.hasCompleted
                      ? () => _handleClearCompleted(context, data.items, cubit)
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
                      if (data.hasCompleted)
                        PlatformAdaptive.textButton(
                          context: context,
                          onPressed: () => _handleClearCompleted(
                            context,
                            data.items,
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
                        sortOrder: data.sortOrder,
                        onSortChanged: cubit.setSortOrder,
                      ),
                    ],
                  ),
                  if (layout.showBatchActions) ...[
                    SizedBox(height: layout.gapS),
                    TodoBatchActionsBar(
                      items: data.items,
                      filteredItems: data.filteredItems,
                      selectedItemIds: data.selectedItemIds,
                      hasSelection: data.hasSelectedItems,
                      cubit: cubit,
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
                child: TodoListContent(
                  filteredItems: data.filteredItems,
                  sortOrder: data.sortOrder,
                  selectedItemIds: data.selectedItemIds,
                  cubit: cubit,
                  onItemSelectionChanged:
                      (
                        final itemId, {
                        required final selected,
                      }) {
                        if (selected != data.selectedItemIds.contains(itemId)) {
                          cubit.toggleItemSelection(itemId);
                        }
                      },
                  onAddTodo: () => _handleAddTodo(context),
                  onEditTodo: (final item) => _handleEditTodo(context, item),
                  onDeleteTodo: (final item) =>
                      _handleDeleteTodo(context, item),
                  onDeleteWithUndo: (final item, final cubit) =>
                      _handleDeleteWithUndo(context, item, cubit),
                ),
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...headerChildren,
                listContent,
              ],
            );
          },
        ),
      );
    },
  );
}

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
    required final TodoListViewData data,
    required final double availableHeight,
  }) {
    // Use window height (not current layout height) so keyboard insets do not
    // flip this branch and steal TextField focus on iOS.
    final bool isSpaceLimited = MediaQuery.sizeOf(context).height < 600;
    final bool isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final double gapM = isSpaceLimited ? context.responsiveGapS : context.responsiveGapM;
    final double gapS = isSpaceLimited ? context.responsiveGapXS : context.responsiveGapS;
    final bool showCompactHeader = isSpaceLimited || isKeyboardVisible;
    final bool showStats = !showCompactHeader && !isKeyboardVisible && availableHeight >= 560;
    final bool shouldKeepSearchVisible = isKeyboardVisible || data.searchQuery.isNotEmpty;
    final bool showSearch =
        data.items.isNotEmpty &&
        (isSpaceLimited || availableHeight >= 120 || shouldKeepSearchVisible);
    final bool showFilterBar = !isKeyboardVisible && availableHeight >= 420;
    final bool showSecondaryControls =
        showFilterBar && data.items.isNotEmpty && !showCompactHeader && availableHeight >= 500;
    final bool showBatchActions = showSecondaryControls && availableHeight >= 560;
    final bool showAddButton =
        showBatchActions && data.filteredItems.isNotEmpty && availableHeight >= 620;

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
}
