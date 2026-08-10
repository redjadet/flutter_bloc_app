import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/app/widgets/view_status_switcher.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/pages/todo_list_page_data.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_batch_actions_bar.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_filter_bar.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_content.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_dialogs.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_search_field.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_sort_bar.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_stats_widget.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

part 'todo_list_page_app_bar.dart';
part 'todo_list_page_body.dart';
part 'todo_list_page_body.part.dart';
part 'todo_list_page_header.part.dart';
part 'todo_list_page_handlers.dart';

enum _BatchMenuAction { complete, uncomplete, delete }

@immutable
class _TodoAppBarData {
  const _TodoAppBarData({
    required this.hasFilteredItems,
    required this.allFilteredSelected,
    required this.hasSelection,
    required this.hasSelectedActive,
    required this.hasSelectedCompleted,
    required this.selectedCount,
  });

  factory _TodoAppBarData.fromProjections({
    required final List<TodoItem> items,
    required final List<TodoItem> filteredItems,
    required final TodoListSelectionData selection,
  }) {
    final ids = selection.selectedItemIds;
    final allSelected =
        filteredItems.isNotEmpty &&
        filteredItems.every((final i) => ids.contains(i.id));
    final hasSelectedActive = items.any(
      (final i) => ids.contains(i.id) && !i.isCompleted,
    );
    final hasSelectedCompleted = items.any(
      (final i) => ids.contains(i.id) && i.isCompleted,
    );
    return _TodoAppBarData(
      hasFilteredItems: filteredItems.isNotEmpty,
      allFilteredSelected: allSelected,
      hasSelection: selection.hasSelectedItems,
      hasSelectedActive: hasSelectedActive,
      hasSelectedCompleted: hasSelectedCompleted,
      selectedCount: selection.selectedCount,
    );
  }

  final bool hasFilteredItems;
  final bool allFilteredSelected;
  final bool hasSelection;
  final bool hasSelectedActive;
  final bool hasSelectedCompleted;
  final int selectedCount;

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _TodoAppBarData &&
        other.hasFilteredItems == hasFilteredItems &&
        other.allFilteredSelected == allFilteredSelected &&
        other.hasSelection == hasSelection &&
        other.hasSelectedActive == hasSelectedActive &&
        other.hasSelectedCompleted == hasSelectedCompleted &&
        other.selectedCount == selectedCount;
  }

  @override
  int get hashCode => Object.hash(
    hasFilteredItems,
    allFilteredSelected,
    hasSelection,
    hasSelectedActive,
    hasSelectedCompleted,
    selectedCount,
  );
}

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    // Outer list projection derives filtered rows only when list inputs change.
    // Inner selection rebuilds app-bar actions without re-filtering.
    return TypeSafeBlocSelector<
      TodoListCubit,
      TodoListState,
      TodoListListProjection
    >(
      selector: TodoListListProjection.fromState,
      builder: (final context, final listData) {
        final List<TodoItem> filteredItems = listData.filteredItems;
        return TypeSafeBlocSelector<
          TodoListCubit,
          TodoListState,
          TodoListSelectionData
        >(
          selector: TodoListSelectionData.fromState,
          builder: (final context, final selection) {
            final _TodoAppBarData barData = _TodoAppBarData.fromProjections(
              items: listData.items,
              filteredItems: filteredItems,
              selection: selection,
            );
            return CommonPageLayout(
              title: l10n.todoListTitle,
              actions: _buildTodoListAppBarActions(context, barData),
              body: const _TodoListBody(),
              floatingActionButton: Semantics(
                button: true,
                label: l10n.todoListAddAction,
                child: FloatingActionButton(
                  onPressed: () => _handleAddTodo(context),
                  tooltip: l10n.todoListAddAction,
                  child: const Icon(Icons.add),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
