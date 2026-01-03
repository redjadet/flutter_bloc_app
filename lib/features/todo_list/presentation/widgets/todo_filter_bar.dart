import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class TodoFilterBar extends StatelessWidget {
  const TodoFilterBar({
    required this.filter,
    required this.hasCompleted,
    required this.onFilterChanged,
    required this.onClearCompleted,
    super.key,
  });

  final TodoFilter filter;
  final bool hasCompleted;
  final ValueChanged<TodoFilter> onFilterChanged;
  final VoidCallback? onClearCompleted;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: context.responsiveHorizontalGapS,
          runSpacing: context.responsiveGapS,
          children: [
            _FilterChip(
              label: l10n.todoListFilterAll,
              isSelected: filter == TodoFilter.all,
              onPressed: () => onFilterChanged(TodoFilter.all),
            ),
            _FilterChip(
              label: l10n.todoListFilterActive,
              isSelected: filter == TodoFilter.active,
              onPressed: () => onFilterChanged(TodoFilter.active),
            ),
            _FilterChip(
              label: l10n.todoListFilterCompleted,
              isSelected: filter == TodoFilter.completed,
              onPressed: () => onFilterChanged(TodoFilter.completed),
            ),
          ],
        ),
        SizedBox(height: context.responsiveGapS),
        Align(
          alignment: Alignment.centerRight,
          child: PlatformAdaptive.textButton(
            context: context,
            onPressed: onClearCompleted,
            child: Text(
              l10n.todoListClearCompletedAction,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: context.responsiveCaptionSize,
                color: onClearCompleted == null
                    ? colors.onSurfaceVariant
                    : colors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final Color backgroundColor = isSelected ? colors.primary : colors.surface;
    final Color foregroundColor = isSelected
        ? colors.onPrimary
        : colors.primary;
    final BorderSide side = BorderSide(
      color: isSelected ? colors.primary : colors.outlineVariant,
      width: context.isDesktop
          ? 1.5
          : context.isTabletOrLarger
          ? 1.3
          : 1.2,
    );

    return PlatformAdaptive.outlinedButton(
      context: context,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
      side: side,
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontSize: context.responsiveCaptionSize,
          fontWeight: FontWeight.w600,
          color: foregroundColor,
        ),
      ),
    );
  }
}
