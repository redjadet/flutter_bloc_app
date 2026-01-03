import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/helpers/todo_list_dialogs.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_empty_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_filter_bar.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_view.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_search_field.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_sort_bar.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_stats_widget.dart';
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
  ) => TypeSafeBlocSelector<TodoListCubit, TodoListState, _TodoListViewData>(
    selector: (final state) => _TodoListViewData(
      isLoading: state.isLoading,
      hasError: state.hasError,
      errorMessage: state.errorMessage,
      items: state.items,
      filteredItems: state.filteredItems,
      filter: state.filter,
      hasCompleted: state.hasCompleted,
      searchQuery: state.searchQuery,
      sortOrder: state.sortOrder,
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

      return CommonMaxWidth(
        maxWidth: context.contentMaxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TodoStatsWidget(),
            if (data.items.isNotEmpty) ...[
              SizedBox(height: context.responsiveGapM),
              const TodoSearchField(),
            ],
            SizedBox(height: context.responsiveGapM),
            TodoFilterBar(
              filter: data.filter,
              hasCompleted: data.hasCompleted,
              onFilterChanged: cubit.setFilter,
              onClearCompleted: data.hasCompleted
                  ? () => cubit.clearCompleted()
                  : null,
            ),
            if (data.items.isNotEmpty) ...[
              SizedBox(height: context.responsiveGapS),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (data.hasCompleted)
                    PlatformAdaptive.textButton(
                      context: context,
                      onPressed: () => cubit.clearCompleted(),
                      child: Text(
                        context.l10n.todoListClearCompletedAction,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: context.responsiveCaptionSize,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  if (data.hasCompleted)
                    SizedBox(width: context.responsiveHorizontalGapS),
                  TodoSortBar(
                    sortOrder: data.sortOrder,
                    onSortChanged: cubit.setSortOrder,
                  ),
                ],
              ),
            ],
            SizedBox(height: context.responsiveGapM),
            Expanded(
              child: data.filteredItems.isEmpty
                  ? RefreshIndicator(
                      onRefresh: () => cubit.refresh(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: TodoEmptyState(
                            onAddTodo: () => _handleAddTodo(context),
                          ),
                        ),
                      ),
                    )
                  : data.sortOrder == TodoSortOrder.manual
                  ? RefreshIndicator(
                      onRefresh: () => cubit.refresh(),
                      child: ReorderableListView.builder(
                        padding: context.responsiveListPadding,
                        cacheExtent: 500,
                        itemCount: data.filteredItems.length,
                        onReorder: (final int oldIndex, final int newIndex) {
                          cubit.reorderItems(
                            oldIndex: oldIndex,
                            newIndex: newIndex,
                          );
                        },
                        itemBuilder: (final context, final index) {
                          final TodoItem item = data.filteredItems[index];
                          return RepaintBoundary(
                            key: ValueKey('todo-${item.id}'),
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: context.responsiveGapS,
                              ),
                              child: TodoListItem(
                                item: item,
                                showDragHandle:
                                    data.sortOrder == TodoSortOrder.manual,
                                onToggle: () => cubit.toggleTodo(item),
                                onEdit: () => _handleEditTodo(context, item),
                                onDelete: () =>
                                    _handleDeleteTodo(context, item),
                                onDeleteWithoutConfirmation: () =>
                                    _handleDeleteWithUndo(
                                      context,
                                      item,
                                      cubit,
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => cubit.refresh(),
                      child: TodoListView(
                        items: data.filteredItems,
                        sortOrder: data.sortOrder,
                        onToggle: (final item) => cubit.toggleTodo(item),
                        onEdit: (final item) => _handleEditTodo(context, item),
                        onDelete: (final item) =>
                            _handleDeleteTodo(context, item),
                        onDeleteWithoutConfirmation: (final item) =>
                            _handleDeleteWithUndo(context, item, cubit),
                      ),
                    ),
            ),
            if (data.filteredItems.isNotEmpty) ...[
              SizedBox(height: context.responsiveGapM),
              PlatformAdaptive.filledButton(
                context: context,
                onPressed: () => _handleAddTodo(context),
                child: Text(context.l10n.todoListAddAction),
              ),
            ],
          ],
        ),
      );
    },
  );
}

@immutable
class _TodoListViewData {
  const _TodoListViewData({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.items,
    required this.filteredItems,
    required this.filter,
    required this.hasCompleted,
    required this.searchQuery,
    required this.sortOrder,
  });

  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<TodoItem> items;
  final List<TodoItem> filteredItems;
  final TodoFilter filter;
  final bool hasCompleted;
  final String searchQuery;
  final TodoSortOrder sortOrder;
}
