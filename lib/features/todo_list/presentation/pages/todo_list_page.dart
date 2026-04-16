import 'dart:async';

import 'package:flutter/gestures.dart';
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
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:flutter_bloc_app/shared/widgets/common_max_width.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

part 'todo_list_page_app_bar.dart';
part 'todo_list_page_body.dart';
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
    return TypeSafeBlocSelector<TodoListCubit, TodoListState, _TodoAppBarData>(
      selector: (final state) {
        final filtered = state.filteredItems;
        final ids = state.selectedItemIds;
        final items = state.items;
        final allSelected =
            filtered.isNotEmpty &&
            filtered.every((final i) => ids.contains(i.id));
        final hasSelectedActive = items.any(
          (final i) => ids.contains(i.id) && !i.isCompleted,
        );
        final hasSelectedCompleted = items.any(
          (final i) => ids.contains(i.id) && i.isCompleted,
        );
        return _TodoAppBarData(
          hasFilteredItems: filtered.isNotEmpty,
          allFilteredSelected: allSelected,
          hasSelection: state.hasSelectedItems,
          hasSelectedActive: hasSelectedActive,
          hasSelectedCompleted: hasSelectedCompleted,
          selectedCount: state.selectedCount,
        );
      },
      builder: (final context, final barData) {
        return CommonPageLayout(
          title: l10n.todoListTitle,
          actions: _buildTodoListAppBarActions(context, barData),
          body: const _TodoListBody(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _handleAddTodo(context),
            tooltip: l10n.todoListAddAction,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
