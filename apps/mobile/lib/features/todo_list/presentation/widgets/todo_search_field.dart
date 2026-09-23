import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mix/mix.dart';

double _todoSearchFontSize(BuildContext context) =>
    context.responsiveBodySize.clamp(14.0, 22.0);

class TodoSearchField extends StatefulWidget {
  const new({super.key});

  @override
  State<TodoSearchField> createState() => _TodoSearchFieldState();
}

class _TodoSearchFieldState extends State<TodoSearchField> {
  late final TextEditingController _controller;
  bool _didSyncInitialQuery = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didSyncInitialQuery) {
      return;
    }
    _didSyncInitialQuery = true;
    _syncControllerToQuery(context.cubit<TodoListCubit>().state.searchQuery);
  }

  void _syncControllerToQuery(String query) {
    if (_controller.text == query) {
      return;
    }
    _controller.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      onChanged: (value) {
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

    final Widget fieldShell = !hasMixTheme
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(
                context.responsiveBorderRadius,
              ),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: textField,
          )
        : Box(style: AppStyles.inputFieldShell, child: textField);

    // Cubit owns searchQuery; keep the controller in sync with external
    // changes (restore, clear-filters, programmatic set) so UI cannot drift.
    return TypeSafeBlocListener<TodoListCubit, TodoListState>(
      listenWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
      listener: (context, state) {
        _syncControllerToQuery(state.searchQuery);
        setState(() {});
      },
      child: fieldShell,
    );
  }
}
