import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/root_aware_back_button.dart';

/// A reusable page layout widget that provides consistent structure
/// across the app with responsive design and common AppBar pattern.
class CommonPageLayout extends StatelessWidget {
  const CommonPageLayout({
    required this.title,
    required this.body,
    super.key,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.persistentFooterButtons,
    this.drawer,
    this.endDrawer,
    this.onWillPop,
    this.automaticallyImplyLeading = true,
    this.useResponsiveBody = true,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final List<Widget>? persistentFooterButtons;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool Function()? onWillPop;
  final bool automaticallyImplyLeading;

  /// Whether to wrap [body] with the shared responsive padding/constraints.
  final bool useResponsiveBody;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final Widget content = useResponsiveBody
        ? _ResponsiveBody(child: body)
        : body;

    return PopScope(
      canPop: onWillPop?.call() ?? true,
      child: Scaffold(
        appBar: _AdaptiveAppBar(
          title: title,
          homeTooltip: l10n.homeTitle,
          actions: actions,
          automaticallyImplyLeading: automaticallyImplyLeading,
        ),
        body: content,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        persistentFooterButtons: persistentFooterButtons,
        drawer: drawer,
        endDrawer: endDrawer,
      ),
    );
  }
}

class _AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AdaptiveAppBar({
    required this.title,
    required this.homeTooltip,
    required this.automaticallyImplyLeading,
    this.actions,
  });

  final String title;
  final String homeTooltip;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;

  bool get _hasActions => actions != null && actions!.isNotEmpty;

  bool _isCupertino(final BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(final BuildContext context) {
    if (_isCupertino(context)) {
      final theme = Theme.of(context);
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
        brightness: theme.brightness,
        middle: DefaultTextStyle(
          style: titleStyle,
          child: Text(title),
        ),
        automaticallyImplyLeading: automaticallyImplyLeading,
        leading: automaticallyImplyLeading
            ? RootAwareBackButton(homeTooltip: homeTooltip)
            : null,
        trailing: _hasActions ? _buildCupertinoActions() : null,
      );
    }

    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: automaticallyImplyLeading
          ? RootAwareBackButton(homeTooltip: homeTooltip)
          : null,
      title: Text(title),
      actions: actions,
    );
  }

  Widget _buildCupertinoActions() {
    if (actions!.length == 1) {
      return actions!.first;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions!,
    );
  }
}

/// Responsive body wrapper that applies consistent padding and constraints
class _ResponsiveBody extends StatelessWidget {
  const _ResponsiveBody({required this.child});

  final Widget child;

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
    builder: (final context, final constraints) => Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.pageHorizontalPadding,
            vertical: context.pageVerticalPadding,
          ),
          child: child,
        ),
      ),
    ),
  );
}
