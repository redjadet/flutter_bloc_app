import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/widgets/common_empty_state.dart';

class TodoEmptyState extends StatelessWidget {
  const TodoEmptyState({required this.onAddTodo, super.key});

  final VoidCallback onAddTodo;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonEmptyState(
      title: l10n.todoListEmptyTitle,
      message: l10n.todoListEmptyMessage,
      icon: Icons.check_circle_outline,
      primaryAction: onAddTodo,
      primaryActionLabel: l10n.todoListAddAction,
    );
  }
}
