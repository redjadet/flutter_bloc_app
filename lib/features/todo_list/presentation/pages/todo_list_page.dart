import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/helpers/todo_list_dialogs.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_empty_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_filter_bar.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_search_field.dart';
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
  Widget build(final BuildContext context) =>
      TypeSafeBlocSelector<TodoListCubit, TodoListState, _TodoListViewData>(
        selector: (final state) => _TodoListViewData(
          isLoading: state.isLoading,
          hasError: state.hasError,
          errorMessage: state.errorMessage,
          items: state.items,
          filteredItems: state.filteredItems,
          filter: state.filter,
          hasCompleted: state.hasCompleted,
          searchQuery: state.searchQuery,
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
                SizedBox(height: context.responsiveGapM),
                Expanded(
                  child: data.filteredItems.isEmpty
                      ? TodoEmptyState(
                          onAddTodo: () => _handleAddTodo(context),
                        )
                      : ListView.separated(
                          padding: context.responsiveListPadding,
                          itemCount: data.filteredItems.length,
                          separatorBuilder: (final _, final _) =>
                              SizedBox(height: context.responsiveGapS),
                          itemBuilder: (final context, final index) {
                            final TodoItem item = data.filteredItems[index];
                            return RepaintBoundary(
                              child: TodoListItem(
                                key: ValueKey('todo-${item.id}'),
                                item: item,
                                onToggle: () => cubit.toggleTodo(item),
                                onEdit: () => _handleEditTodo(context, item),
                                onDelete: () =>
                                    _handleDeleteTodo(context, item),
                                onDeleteWithoutConfirmation: () =>
                                    _handleDeleteWithUndo(context, item, cubit),
                              ),
                            );
                          },
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
  });

  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<TodoItem> items;
  final List<TodoItem> filteredItems;
  final TodoFilter filter;
  final bool hasCompleted;
  final String searchQuery;
}

Future<void> _handleAddTodo(final BuildContext context) async {
  final TodoEditorResult? result = await showTodoEditorDialog(context: context);
  if (result == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
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
