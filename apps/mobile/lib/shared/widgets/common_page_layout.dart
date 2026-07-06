import 'dart:math' as math;

import 'package:design_system/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/widgets/common_app_bar.dart';

/// A reusable page layout widget that provides consistent structure
/// across the app with responsive design and common AppBar pattern.
class CommonPageLayout extends StatelessWidget {
  const CommonPageLayout({
    required this.body,
    super.key,
    this.title = '',
    this.appBar,
    this.actions,
    this.appBarBackgroundColor,
    this.appBarForegroundColor,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.persistentFooterButtons,
    this.drawer,
    this.endDrawer,
    this.onWillPop,
    this.automaticallyImplyLeading = true,
    this.useResponsiveBody = true,
    this.titleTextStyle,
    this.cupertinoTitleStyle,
    this.appBarElevation,
    this.systemOverlayStyle,
    this.centerTitle,
    this.floatingActionButtonLocation,
    this.backgroundColor,
  });

  /// Material/Cupertino title when [appBar] is null.
  final String title;

  /// Custom app bar. When set, [title] and standard app bar params are ignored.
  final PreferredSizeWidget? appBar;

  /// Optional custom app bar background color (applied to both Material
  /// and Cupertino navigation bars).
  final Color? appBarBackgroundColor;

  /// Optional custom app bar foreground color (icons, title).
  final Color? appBarForegroundColor;
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

  /// Optional Material app bar title style.
  final TextStyle? titleTextStyle;

  /// Optional Cupertino navigation bar title style.
  final TextStyle? cupertinoTitleStyle;

  /// Optional Material app bar elevation (also sets scrolled-under elevation).
  final double? appBarElevation;

  /// Optional status bar / system overlay styling for the app bar region.
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// Optional Material app bar title centering (passed through to [CommonAppBar]).
  final bool? centerTitle;

  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Optional [Scaffold] background; defaults to theme scaffold background.
  final Color? backgroundColor;

  @override
  Widget build(final BuildContext context) {
    assert(
      appBar != null || title.isNotEmpty,
      'CommonPageLayout requires a non-empty title or a custom appBar.',
    );
    final PreferredSizeWidget resolvedAppBar =
        appBar ?? _buildDefaultAppBar(context);
    final Widget content = useResponsiveBody
        ? _ResponsiveBody(child: body)
        : body;

    return PopScope(
      canPop: onWillPop?.call() ?? true,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: resolvedAppBar,
        body: content,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
        persistentFooterButtons: persistentFooterButtons,
        drawer: drawer,
        endDrawer: endDrawer,
      ),
    );
  }

  PreferredSizeWidget _buildDefaultAppBar(final BuildContext context) {
    final l10n = context.l10n;
    return CommonAppBar(
      title: title,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      homeTooltip: l10n.homeTitle,
      backgroundColor: appBarBackgroundColor,
      foregroundColor: appBarForegroundColor,
      titleTextStyle: titleTextStyle,
      cupertinoBackgroundColor: appBarBackgroundColor,
      cupertinoTitleStyle: cupertinoTitleStyle,
      elevation: appBarElevation,
      systemOverlayStyle: systemOverlayStyle,
      centerTitle: centerTitle,
    );
  }
}

/// Responsive body wrapper that applies consistent padding and constraints
class _ResponsiveBody extends StatelessWidget {
  const _ResponsiveBody({required this.child});

  final Widget child;

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
    builder: (final context, final constraints) {
      final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
      final double bottomInset = math.max(context.bottomInset, keyboardInset);
      final EdgeInsets resolvedPadding = EdgeInsets.fromLTRB(
        context.pageHorizontalPadding,
        context.pageVerticalPadding,
        context.pageHorizontalPadding,
        context.pageVerticalPadding + bottomInset,
      );

      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: resolvedPadding,
            child: child,
          ),
        ),
      );
    },
  );
}
