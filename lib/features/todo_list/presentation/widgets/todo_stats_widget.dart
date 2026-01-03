import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

class TodoStatsWidget extends StatelessWidget {
  const TodoStatsWidget({super.key});

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TypeSafeBlocSelector<TodoListCubit, TodoListState, _TodoStatsData>(
      selector: (final state) => _TodoStatsData(
        total: state.items.length,
        completed: state.items.where((final item) => item.isCompleted).length,
        active: state.items.where((final item) => !item.isCompleted).length,
      ),
      builder: (final context, final data) {
        if (data.total == 0) {
          return const SizedBox.shrink();
        }

        return CommonCard(
          color: colors.surfaceContainerHighest,
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveHorizontalGapM,
            vertical: context.responsiveGapS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: context.l10n.todoListFilterAll,
                value: data.total,
                color: colors.primary,
              ),
              _StatItem(
                label: context.l10n.todoListFilterActive,
                value: data.active,
                color: colors.tertiary,
              ),
              _StatItem(
                label: context.l10n.todoListFilterCompleted,
                value: data.completed,
                color: colors.secondary,
              ),
            ],
          ),
        );
      },
    );
  }
}

@immutable
class _TodoStatsData {
  const _TodoStatsData({
    required this.total,
    required this.completed,
    required this.active,
  });

  final int total;
  final int completed;
  final int active;
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: context.responsiveTitleSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: context.responsiveGapXS / 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: context.responsiveCaptionSize,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
