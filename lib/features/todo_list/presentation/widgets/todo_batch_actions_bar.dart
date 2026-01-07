import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/helpers/todo_list_dialogs.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class TodoBatchActionsBar extends StatelessWidget {
  const TodoBatchActionsBar({
    required this.items,
    required this.filteredItems,
    required this.selectedItemIds,
    required this.hasSelection,
    required this.cubit,
    super.key,
  });

  final List<TodoItem> items;
  final List<TodoItem> filteredItems;
  final Set<String> selectedItemIds;
  final bool hasSelection;
  final TodoListCubit cubit;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bool hasSelectedCompleted = items.any(
      (final item) => selectedItemIds.contains(item.id) && item.isCompleted,
    );
    final bool hasSelectedActive = items.any(
      (final item) => selectedItemIds.contains(item.id) && !item.isCompleted,
    );

    // Check if all filtered items are selected
    final Set<String> filteredItemIds = filteredItems
        .map((final item) => item.id)
        .toSet();
    final bool allFilteredItemsSelected =
        filteredItems.isNotEmpty &&
        filteredItemIds.every((final id) => selectedItemIds.contains(id));

    return Wrap(
      spacing: context.responsiveHorizontalGapS,
      runSpacing: context.responsiveGapXS,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (hasSelection)
          Text(
            context.l10n.todoListItemsSelected(selectedItemIds.length),
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: context.responsiveCaptionSize,
              color: colors.onSurface,
            ),
          ),
        if (filteredItems.isNotEmpty)
          PlatformAdaptive.textButton(
            context: context,
            onPressed: allFilteredItemsSelected
                ? cubit.clearSelection
                : cubit.selectAllItems,
            child: Text(
              allFilteredItemsSelected
                  ? context.l10n.todoListClearSelection
                  : context.l10n.todoListSelectAll,
            ),
          ),
        if (hasSelectedActive)
          PlatformAdaptive.textButton(
            context: context,
            onPressed: () async {
              await cubit.batchCompleteSelected();
            },
            child: Text(context.l10n.todoListBatchComplete),
          ),
        if (hasSelectedCompleted)
          PlatformAdaptive.textButton(
            context: context,
            onPressed: () async {
              await cubit.batchUncompleteSelected();
            },
            child: Text(context.l10n.todoListBatchUncomplete),
          ),
        if (hasSelection)
          PlatformAdaptive.textButton(
            context: context,
            onPressed: () async {
              final bool? shouldDelete = await showTodoBatchDeleteConfirmDialog(
                context: context,
                count: selectedItemIds.length,
              );
              if ((shouldDelete ?? false) && context.mounted) {
                await cubit.batchDeleteSelected();
              }
            },
            color: colors.error,
            child: Text(context.l10n.todoListBatchDelete),
          ),
      ],
    );
  }
}
