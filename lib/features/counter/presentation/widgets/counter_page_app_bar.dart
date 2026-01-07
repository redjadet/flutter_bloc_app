import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/counter_page_app_bar_helpers.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/utils/context_utils.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:go_router/go_router.dart';

class CounterPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CounterPageAppBar({
    required this.title,
    required this.onOpenSettings,
    super.key,
  });

  final String title;
  final VoidCallback onOpenSettings;
  static const String _moreTooltip = 'More';
  static final List<OverflowItem> _overflowItems = <OverflowItem>[
    OverflowItem(
      action: OverflowAction.charts,
      routeName: AppRoutes.charts,
      labelBuilder: (final l10n) => l10n.openChartsTooltip,
    ),
    OverflowItem(
      action: OverflowAction.graphql,
      routeName: AppRoutes.graphql,
      labelBuilder: (final l10n) => l10n.openGraphqlTooltip,
    ),
    OverflowItem(
      action: OverflowAction.chat,
      routeName: AppRoutes.chat,
      labelBuilder: (final l10n) => l10n.openChatTooltip,
    ),
    OverflowItem(
      action: OverflowAction.googleMaps,
      routeName: AppRoutes.googleMaps,
      labelBuilder: (final l10n) => l10n.openGoogleMapsTooltip,
    ),
    OverflowItem(
      action: OverflowAction.whiteboard,
      routeName: AppRoutes.whiteboard,
      labelBuilder: (final l10n) => l10n.openWhiteboardTooltip,
    ),
    OverflowItem(
      action: OverflowAction.markdownEditor,
      routeName: AppRoutes.markdownEditor,
      labelBuilder: (final l10n) => l10n.openMarkdownEditorTooltip,
    ),
    OverflowItem(
      action: OverflowAction.todo,
      routeName: AppRoutes.todoList,
      labelBuilder: (final l10n) => l10n.openTodoTooltip,
    ),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final bool useCupertino = _isCupertinoPlatform(theme.platform);
    return useCupertino
        ? _buildCupertinoAppBar(context, theme, l10n)
        : _buildMaterialAppBar(context, theme, l10n);
  }

  AppBar _buildMaterialAppBar(
    final BuildContext context,
    final ThemeData theme,
    final AppLocalizations l10n,
  ) => AppBar(
    backgroundColor: theme.colorScheme.inversePrimary,
    title: Text(
      title,
      style: theme.textTheme.titleLarge,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    actions: [
      IconButton(
        tooltip: l10n.openCalculatorTooltip,
        onPressed: () => context.pushNamed(AppRoutes.calculator),
        icon: const Icon(Icons.payments_outlined),
      ),
      IconButton(
        tooltip: l10n.openExampleTooltip,
        onPressed: () => context.pushNamed(AppRoutes.example),
        icon: const Icon(Icons.explore),
      ),
      IconButton(
        tooltip: l10n.openSettingsTooltip,
        onPressed: onOpenSettings,
        icon: const Icon(Icons.settings),
      ),
      PopupMenuButton<OverflowAction>(
        tooltip: _moreTooltip,
        onSelected: (final action) => _handleOverflowSelection(
          context,
          action,
        ),
        itemBuilder: (final context) => _overflowItems
            .map(
              (final item) => PopupMenuItem<OverflowAction>(
                value: item.action,
                child: Text(item.labelBuilder(l10n)),
              ),
            )
            .toList(),
      ),
    ],
  );

  CupertinoNavigationBar _buildCupertinoAppBar(
    final BuildContext context,
    final ThemeData theme,
    final AppLocalizations l10n,
  ) {
    final colorScheme = theme.colorScheme;
    final TextStyle titleStyle =
        theme.textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
        ) ??
        TextStyle(
          color: colorScheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        );

    return CupertinoNavigationBar(
      backgroundColor: colorScheme.surface.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.98 : 1,
      ),
      middle: DefaultTextStyle(style: titleStyle, child: Text(title)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoIconButton(
            icon: CupertinoIcons.money_dollar,
            onPressed: () => context.pushNamed(AppRoutes.calculator),
            tooltip: l10n.openCalculatorTooltip,
          ),
          CupertinoIconButton(
            icon: CupertinoIcons.compass,
            onPressed: () => context.pushNamed(AppRoutes.example),
            tooltip: l10n.openExampleTooltip,
          ),
          CupertinoIconButton(
            icon: CupertinoIcons.settings,
            onPressed: onOpenSettings,
            tooltip: l10n.openSettingsTooltip,
          ),
          CupertinoIconButton(
            icon: CupertinoIcons.ellipsis_vertical,
            onPressed: () => _showOverflowSheet(context, l10n),
            tooltip: _moreTooltip,
          ),
        ],
      ),
    );
  }

  Future<void> _showOverflowSheet(
    final BuildContext context,
    final AppLocalizations l10n,
  ) async {
    final BuildContext parentContext = context;
    await showCupertinoModalPopup<void>(
      context: parentContext,
      builder: (final sheetContext) => CupertinoActionSheet(
        title: const Text(_moreTooltip),
        actions: _overflowItems
            .map(
              (final item) => CupertinoActionSheetAction(
                onPressed: () {
                  NavigationUtils.maybePop(sheetContext);
                  _navigateToOverflowItem(parentContext, item);
                },
                child: Text(item.labelBuilder(l10n)),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => NavigationUtils.maybePop(sheetContext),
          child: Text(l10n.cancelButtonLabel),
        ),
      ),
    );
  }

  void _handleOverflowSelection(
    final BuildContext context,
    final OverflowAction action,
  ) {
    // Defensive check: ensure overflow items list is not empty
    if (_overflowItems.isEmpty) {
      return;
    }
    final OverflowItem item = _overflowItems.firstWhere(
      (final entry) => entry.action == action,
      orElse: () => _overflowItems.first,
    );
    _navigateToOverflowItem(context, item);
  }

  void _navigateToOverflowItem(
    final BuildContext context,
    final OverflowItem item,
  ) {
    if (!context.mounted) {
      ContextUtils.logNotMounted(
        'CounterPageAppBar._navigateToOverflowItem',
      );
      return;
    }
    unawaited(context.pushNamed(item.routeName));
  }

  bool _isCupertinoPlatform(final TargetPlatform platform) =>
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
}
