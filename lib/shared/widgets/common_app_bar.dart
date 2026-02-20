import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/root_aware_back_button.dart';

/// A reusable AppBar widget that provides consistent styling and behavior
/// across the app with automatic back button handling.
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    required this.title,
    super.key,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.homeTooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.titleTextStyle,
    this.cupertinoBackgroundColor,
    this.cupertinoTitleStyle,
    this.centerTitle,
    this.systemOverlayStyle,
  });

  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final String? homeTooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? titleTextStyle;
  final Color? cupertinoBackgroundColor;
  final TextStyle? cupertinoTitleStyle;
  final bool? centerTitle;
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final String effectiveHomeTooltip = homeTooltip ?? l10n.homeTitle;
    final bool useCupertino = PlatformAdaptive.isCupertinoFromTheme(theme);
    final bool hasActions = switch (actions) {
      final list? when list.isNotEmpty => true,
      _ => false,
    };

    if (useCupertino) {
      final colorScheme = theme.colorScheme;
      final Color resolvedBackgroundColor =
          cupertinoBackgroundColor ??
          colorScheme.surface.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.98 : 1,
          );
      final TextStyle titleStyle =
          cupertinoTitleStyle ??
          theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
          ) ??
          TextStyle(
            color: colorScheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          );

      return CupertinoNavigationBar(
        backgroundColor: resolvedBackgroundColor,
        brightness: theme.brightness,
        automaticallyImplyLeading: automaticallyImplyLeading,
        leading: automaticallyImplyLeading
            ? RootAwareBackButton(homeTooltip: effectiveHomeTooltip)
            : null,
        middle: DefaultTextStyle(
          style: titleStyle,
          child: Text(title),
        ),
        trailing: hasActions ? _buildCupertinoActions() : null,
      );
    }

    return AppBar(
      leading: automaticallyImplyLeading
          ? RootAwareBackButton(homeTooltip: effectiveHomeTooltip)
          : null,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      title: Text(title, style: titleTextStyle),
      centerTitle: centerTitle,
      systemOverlayStyle: systemOverlayStyle,
      actions: actions,
    );
  }

  Widget _buildCupertinoActions() {
    final List<Widget>? actionList = actions;
    if (actionList case final list?) {
      if (list.length == 1) return list.first;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
