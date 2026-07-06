import 'package:design_system/responsive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/utils/context_utils.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:go_router/go_router.dart';

part 'profile_bottom_nav_handlers.part.dart';
part 'profile_bottom_nav_models.part.dart';

class ProfileBottomNav extends StatelessWidget {
  const ProfileBottomNav({super.key});

  @override
  Widget build(final BuildContext context) {
    final double bottomPadding = context.safeAreaInsets.bottom;
    final ThemeData theme = Theme.of(context);
    final bool useCupertino = PlatformAdaptive.isCupertinoFromTheme(theme);
    final String currentLocation = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.toString();

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: _AdaptiveBottomNavBar(
        items: _navItems,
        selectedIndex: _resolveSelectedIndex(currentLocation),
        currentLocation: currentLocation,
        useCupertino: useCupertino,
      ),
    );
  }
}

class _AdaptiveBottomNavBar extends StatelessWidget {
  const _AdaptiveBottomNavBar({
    required this.items,
    required this.selectedIndex,
    required this.currentLocation,
    required this.useCupertino,
  });

  final List<_NavItem> items;
  final int selectedIndex;
  final String currentLocation;
  final bool useCupertino;

  List<BottomNavigationBarItem> get _navigationBarItems => items
      .map(
        (final item) => BottomNavigationBarItem(
          icon: Icon(useCupertino ? item.cupertinoIcon : item.materialIcon),
          label: item.label,
        ),
      )
      .toList();

  Future<void> _onTap(final BuildContext context, final int index) =>
      _handleTap(context, items[index], currentLocation);

  @override
  Widget build(final BuildContext context) {
    if (useCupertino) {
      return CupertinoTabBar(
        currentIndex: selectedIndex,
        items: _navigationBarItems,
        onTap: (final index) => _onTap(context, index),
      );
    }
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: (final index) => _onTap(context, index),
      items: _navigationBarItems,
    );
  }
}
