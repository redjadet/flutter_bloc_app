import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
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
        PlatformAdaptive.textButton(
          context: context,
          onPressed: filteredItems.isNotEmpty ? cubit.selectAllItems : null,
          child: Text(context.l10n.todoListSelectAll),
        ),
        PlatformAdaptive.textButton(
          context: context,
          onPressed: hasSelection ? cubit.clearSelection : null,
          child: Text(context.l10n.todoListClearSelection),
        ),
        PlatformAdaptive.textButton(
          context: context,
          onPressed: hasSelectedActive
              ? () async {
                  await cubit.batchCompleteSelected();
                }
              : null,
          child: Text(context.l10n.todoListBatchComplete),
        ),
        PlatformAdaptive.textButton(
          context: context,
          onPressed: hasSelectedCompleted
              ? () async {
                  await cubit.batchUncompleteSelected();
                }
              : null,
          child: Text(context.l10n.todoListBatchUncomplete),
        ),
        PlatformAdaptive.textButton(
          context: context,
          onPressed: hasSelection
              ? () async {
                  await cubit.batchDeleteSelected();
                }
              : null,
          color: colors.error,
          child: Text(context.l10n.todoListBatchDelete),
        ),
      ],
    );
  }
}
