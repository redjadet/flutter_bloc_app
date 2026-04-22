import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:mix/mix.dart';

double _todoSearchFontSize(final BuildContext context) =>
    context.responsiveBodySize.clamp(14.0, 22.0);

class TodoSearchField extends StatefulWidget {
  const TodoSearchField({super.key});

  @override
  State<TodoSearchField> createState() => _TodoSearchFieldState();
}

class _TodoSearchFieldState extends State<TodoSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final double iconSize = math.min(context.responsiveIconSize, 28);
    final bool hasMixTheme = MixScope.maybeOf(context) != null;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurface,
      fontSize: _todoSearchFontSize(context),
    );
    final hintStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
      fontSize: _todoSearchFontSize(context),
    );

    final EdgeInsets contentPadding = EdgeInsets.symmetric(
      horizontal: context.responsiveHorizontalGapM.clamp(10.0, 24.0),
      vertical: context.responsiveGapM.clamp(10.0, 18.0),
    );

    final Widget textField = TextField(
      controller: _controller,
      onChanged: (final value) {
        setState(() {});
        // Debouncing is handled in the cubit
        context.cubit<TodoListCubit>().setSearchQuery(value);
      },
      style: textStyle,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: contentPadding,
        hintText: l10n.todoListSearchHint,
        hintStyle: hintStyle,
        prefixIcon: Icon(
          Icons.search,
          color: colors.onSurfaceVariant,
          size: iconSize,
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth:
              iconSize + context.responsiveHorizontalGapM.clamp(10.0, 24.0),
          minHeight: iconSize,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: colors.onSurfaceVariant,
                  size: iconSize,
                ),
                onPressed: () {
                  setState(() {
                    _controller.clear();
                  });
                  context.cubit<TodoListCubit>().setSearchQuery('');
                },
              )
            : null,
        suffixIconConstraints: BoxConstraints(
          minWidth:
              iconSize + context.responsiveHorizontalGapM.clamp(10.0, 24.0),
          minHeight: iconSize,
        ),
      ),
      textAlignVertical: TextAlignVertical.center,
    );

    if (!hasMixTheme) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
          border: Border.all(
            color: colors.outlineVariant,
          ),
        ),
        child: textField,
      );
    }

    return Box(
      style: AppStyles.inputFieldShell,
      child: textField,
    );
  }
}
