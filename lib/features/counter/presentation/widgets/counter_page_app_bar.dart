import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
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
  static final List<_OverflowItem> _overflowItems = <_OverflowItem>[
    _OverflowItem(
      action: _OverflowAction.charts,
      routeName: AppRoutes.charts,
      labelBuilder: (final l10n) => l10n.openChartsTooltip,
    ),
    _OverflowItem(
      action: _OverflowAction.graphql,
      routeName: AppRoutes.graphql,
      labelBuilder: (final l10n) => l10n.openGraphqlTooltip,
    ),
    _OverflowItem(
      action: _OverflowAction.chat,
      routeName: AppRoutes.chat,
      labelBuilder: (final l10n) => l10n.openChatTooltip,
    ),
    _OverflowItem(
      action: _OverflowAction.googleMaps,
      routeName: AppRoutes.googleMaps,
      labelBuilder: (final l10n) => l10n.openGoogleMapsTooltip,
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
      PopupMenuButton<_OverflowAction>(
        tooltip: _moreTooltip,
        onSelected: (final action) => _handleOverflowSelection(
          context,
          action,
        ),
        itemBuilder: (final context) => _overflowItems
            .map(
              (final item) => PopupMenuItem<_OverflowAction>(
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
          _CupertinoIconButton(
            icon: CupertinoIcons.money_dollar,
            onPressed: () => context.pushNamed(AppRoutes.calculator),
            tooltip: l10n.openCalculatorTooltip,
          ),
          _CupertinoIconButton(
            icon: CupertinoIcons.compass,
            onPressed: () => context.pushNamed(AppRoutes.example),
            tooltip: l10n.openExampleTooltip,
          ),
          _CupertinoIconButton(
            icon: CupertinoIcons.settings,
            onPressed: onOpenSettings,
            tooltip: l10n.openSettingsTooltip,
          ),
          _CupertinoIconButton(
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
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (final context) => CupertinoActionSheet(
        title: const Text(_moreTooltip),
        actions: _overflowItems
            .map(
              (final item) => CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigateToOverflowItem(context, item);
                },
                child: Text(item.labelBuilder(l10n)),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButtonLabel),
        ),
      ),
    );
  }

  void _handleOverflowSelection(
    final BuildContext context,
    final _OverflowAction action,
  ) {
    final _OverflowItem item = _overflowItems.firstWhere(
      (final entry) => entry.action == action,
      orElse: () => _overflowItems.first,
    );
    _navigateToOverflowItem(context, item);
  }

  void _navigateToOverflowItem(
    final BuildContext context,
    final _OverflowItem item,
  ) {
    unawaited(context.pushNamed(item.routeName));
  }

  bool _isCupertinoPlatform(final TargetPlatform platform) =>
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
}

enum _OverflowAction { charts, graphql, chat, googleMaps }

class _OverflowItem {
  const _OverflowItem({
    required this.action,
    required this.routeName,
    required this.labelBuilder,
  });

  final _OverflowAction action;
  final String routeName;
  final String Function(AppLocalizations l10n) labelBuilder;
}

class _CupertinoIconButton extends StatelessWidget {
  const _CupertinoIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(final BuildContext context) => Tooltip(
    message: tooltip,
    child: CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Icon(icon, size: 22),
    ),
  );
}
