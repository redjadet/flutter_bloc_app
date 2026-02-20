import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/context_utils.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:go_router/go_router.dart';

class _NavDestination {
  const _NavDestination({
    required this.materialIcon,
    required this.cupertinoIcon,
    required this.label,
    required this.route,
  });

  final IconData materialIcon;
  final IconData cupertinoIcon;
  final String label;
  final String route;

  bool matches(final String location) {
    final String path = Uri.parse(location).path;
    return path == route || path.endsWith(route);
  }
}

class _NavItem {
  const _NavItem.destination(this.destination)
    : isAction = false,
      _labelOverride = null,
      _materialIconOverride = null,
      _cupertinoIconOverride = null;

  const _NavItem.action({
    required final String label,
    required final IconData materialIcon,
    required final IconData cupertinoIcon,
  }) : destination = null,
       isAction = true,
       _labelOverride = label,
       _materialIconOverride = materialIcon,
       _cupertinoIconOverride = cupertinoIcon;

  final _NavDestination? destination;
  final bool isAction;
  final String? _labelOverride;
  final IconData? _materialIconOverride;
  final IconData? _cupertinoIconOverride;

  String get label => switch ((destination?.label, _labelOverride)) {
    (final l?, _) => l,
    (_, final o?) => o,
    _ => throw StateError('_NavItem: destination or label override required'),
  };
  IconData get materialIcon => switch ((
    destination?.materialIcon,
    _materialIconOverride,
  )) {
    (final i?, _) => i,
    (_, final o?) => o,
    _ => throw StateError(
      '_NavItem: destination or materialIcon override required',
    ),
  };
  IconData get cupertinoIcon => switch ((
    destination?.cupertinoIcon,
    _cupertinoIconOverride,
  )) {
    (final i?, _) => i,
    (_, final o?) => o,
    _ => throw StateError(
      '_NavItem: destination or cupertinoIcon override required',
    ),
  };
}

const int _profileTabIndex = 0;

List<_NavItem> _buildNavItems() => const <_NavItem>[
  _NavItem.destination(
    _NavDestination(
      materialIcon: Icons.person_outline,
      cupertinoIcon: CupertinoIcons.person,
      label: 'Profile',
      route: AppRoutes.profilePath,
    ),
  ),
  _NavItem.destination(
    _NavDestination(
      materialIcon: Icons.search,
      cupertinoIcon: CupertinoIcons.search,
      label: 'Search',
      route: AppRoutes.searchPath,
    ),
  ),
  _NavItem.action(
    label: 'Add',
    materialIcon: Icons.add,
    cupertinoIcon: CupertinoIcons.add,
  ),
  _NavItem.destination(
    _NavDestination(
      materialIcon: Icons.chat_bubble_outline,
      cupertinoIcon: CupertinoIcons.chat_bubble,
      label: 'Chat',
      route: AppRoutes.chatListPath,
    ),
  ),
  _NavItem.destination(
    _NavDestination(
      materialIcon: Icons.widgets_outlined,
      cupertinoIcon: CupertinoIcons.square_grid_2x2,
      label: 'Example',
      route: AppRoutes.examplePath,
    ),
  ),
];

class ProfileBottomNav extends StatelessWidget {
  const ProfileBottomNav({super.key});

  @override
  Widget build(final BuildContext context) {
    final double bottomPadding = context.safeAreaInsets.bottom;
    final ThemeData theme = Theme.of(context);
    final bool useCupertino = PlatformAdaptive.isCupertinoFromTheme(theme);
    final GoRouter router = GoRouter.of(context);
    final String currentLocation = router
        .routerDelegate
        .currentConfiguration
        .uri
        .toString();
    final List<_NavItem> items = _buildNavItems();
    const int selectedIndex = 0;
    const int effectiveIndex = selectedIndex >= 0
        ? selectedIndex
        : _profileTabIndex;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: _AdaptiveBottomNavBar(
        items: items,
        selectedIndex: effectiveIndex,
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

  List<BottomNavigationBarItem> get _navItems => items
      .map(
        (final item) => BottomNavigationBarItem(
          icon: Icon(useCupertino ? item.cupertinoIcon : item.materialIcon),
          label: item.label,
        ),
      )
      .toList();

  @override
  Widget build(final BuildContext context) {
    if (useCupertino) {
      return CupertinoTabBar(
        currentIndex: selectedIndex,
        items: _navItems,
        onTap: (final index) => _handleTap(
          context,
          items[index],
          currentLocation,
        ),
      );
    }
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: (final index) => _handleTap(
        context,
        items[index],
        currentLocation,
      ),
      items: _navItems,
    );
  }
}

Future<void> _handleTap(
  final BuildContext context,
  final _NavItem item,
  final String currentLocation,
) async {
  final _NavDestination? destination = item.destination;
  if (destination == null) {
    if (!context.mounted) {
      ContextUtils.logNotMounted('ProfileBottomNav._handleTap.action');
      return;
    }
    await context.push(AppRoutes.registerPath);
    return;
  }
  if (destination.route == AppRoutes.profilePath) {
    return;
  }
  if (destination.matches(currentLocation)) {
    return;
  }
  if (destination.route == AppRoutes.examplePath) {
    if (!context.mounted) {
      ContextUtils.logNotMounted('ProfileBottomNav._handleTap.example');
      return;
    }
    if (!NavigationUtils.maybePop(context)) {
      context.go(AppRoutes.examplePath);
    }
    return;
  }
  if (!context.mounted) {
    ContextUtils.logNotMounted('ProfileBottomNav._handleTap.navigate');
    return;
  }
  await context.push(destination.route);
}
