import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
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
    final AppLocalizations l10n = AppLocalizations.of(context);
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
          tooltip: l10n.openChartsTooltip,
          onPressed: () => context.pushNamed(AppRoutes.charts),
          icon: const Icon(Icons.show_chart),
        ),
        IconButton(
          tooltip: l10n.openGraphqlTooltip,
          onPressed: () => context.pushNamed(AppRoutes.graphql),
          icon: const Icon(Icons.public),
        ),
        IconButton(
          tooltip: l10n.openChatTooltip,
          onPressed: () => context.pushNamed(AppRoutes.chat),
          icon: const Icon(Icons.forum),
        ),
        IconButton(
          tooltip: l10n.openGoogleMapsTooltip,
          onPressed: () => context.pushNamed(AppRoutes.googleMaps),
          icon: const Icon(Icons.map),
        ),
        IconButton(
          tooltip: l10n.openSettingsTooltip,
          onPressed: onOpenSettings,
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }
}
