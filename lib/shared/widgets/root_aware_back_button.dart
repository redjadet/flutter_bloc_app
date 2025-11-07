import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';

/// Displays a back button when the navigator can pop, otherwise a home button.
class RootAwareBackButton extends StatelessWidget {
  const RootAwareBackButton({required this.homeTooltip, super.key});

  final String homeTooltip;

  @override
  Widget build(final BuildContext context) {
    final navigator = Navigator.of(context);
    final bool useCupertino = _isCupertinoPlatform(context);
    void handleNavigation() => NavigationUtils.popOrGoHome(context);

    return navigator.canPop()
        ? _buildBackButton(useCupertino, handleNavigation, context)
        : _buildHomeButton(useCupertino, handleNavigation);
  }

  bool _isCupertinoPlatform(final BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  Widget _buildBackButton(
    final bool useCupertino,
    final VoidCallback onPressed,
    final BuildContext context,
  ) => useCupertino
      ? CupertinoNavigationBarBackButton(
          color: CupertinoTheme.of(context).primaryColor,
          onPressed: onPressed,
        )
      : IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: homeTooltip,
          onPressed: onPressed,
        );

  Widget _buildHomeButton(
    final bool useCupertino,
    final VoidCallback onPressed,
  ) => useCupertino
      ? Tooltip(
          message: homeTooltip,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            child: const Icon(CupertinoIcons.home, size: 28),
          ),
        )
      : IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: homeTooltip,
          onPressed: onPressed,
        );
}
