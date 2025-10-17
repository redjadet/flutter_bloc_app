import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/widgets/root_aware_back_button.dart';

/// A reusable AppBar widget that provides consistent styling and behavior
/// across the app with automatic back button handling.
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.homeTooltip,
  });

  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final String? homeTooltip;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final String effectiveHomeTooltip = homeTooltip ?? l10n.homeTitle;

    return AppBar(
      leading: automaticallyImplyLeading
          ? RootAwareBackButton(homeTooltip: effectiveHomeTooltip)
          : null,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      title: Text(title),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
