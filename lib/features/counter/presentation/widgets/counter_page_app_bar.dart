import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    return AppBar(
      backgroundColor: theme.colorScheme.inversePrimary,
      title: Text(
        title,
        style: theme.textTheme.titleLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
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
          tooltip: 'More',
          onSelected: (final action) {
            switch (action) {
              case _OverflowAction.charts:
                unawaited(context.pushNamed(AppRoutes.charts));
              case _OverflowAction.graphql:
                unawaited(context.pushNamed(AppRoutes.graphql));
              case _OverflowAction.chat:
                unawaited(context.pushNamed(AppRoutes.chat));
              case _OverflowAction.googleMaps:
                unawaited(context.pushNamed(AppRoutes.googleMaps));
            }
          },
          itemBuilder: (final context) => <PopupMenuEntry<_OverflowAction>>[
            PopupMenuItem<_OverflowAction>(
              value: _OverflowAction.charts,
              child: Text(l10n.openChartsTooltip),
            ),
            PopupMenuItem<_OverflowAction>(
              value: _OverflowAction.graphql,
              child: Text(l10n.openGraphqlTooltip),
            ),
            PopupMenuItem<_OverflowAction>(
              value: _OverflowAction.chat,
              child: Text(l10n.openChatTooltip),
            ),
            PopupMenuItem<_OverflowAction>(
              value: _OverflowAction.googleMaps,
              child: Text(l10n.openGoogleMapsTooltip),
            ),
          ],
        ),
      ],
    );
  }
}

enum _OverflowAction { charts, graphql, chat, googleMaps }
