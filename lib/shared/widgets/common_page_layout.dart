import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/root_aware_back_button.dart';

/// A reusable page layout widget that provides consistent structure
/// across the app with responsive design and common AppBar pattern.
class CommonPageLayout extends StatelessWidget {
  const CommonPageLayout({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.persistentFooterButtons,
    this.drawer,
    this.endDrawer,
    this.onWillPop,
    this.automaticallyImplyLeading = true,
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

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
        body: _ResponsiveBody(child: body),
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
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
        );
      },
    );
  }
}
