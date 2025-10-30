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
        appBar: AppBar(
          leading: automaticallyImplyLeading
              ? RootAwareBackButton(homeTooltip: l10n.homeTitle)
              : null,
          automaticallyImplyLeading: automaticallyImplyLeading,
          title: Text(title),
          actions: actions,
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
