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
    final String path = Uri.tryParse(location)?.path ?? '/';
    return path == route || path.endsWith(route);
  }
}

class _NavItem {
  const _NavItem.destination(this.destination)
    : _labelOverride = null,
      _materialIconOverride = null,
      _cupertinoIconOverride = null;

  const _NavItem.action({
    required final String label,
    required final IconData materialIcon,
    required final IconData cupertinoIcon,
  }) : destination = null,
       _labelOverride = label,
       _materialIconOverride = materialIcon,
       _cupertinoIconOverride = cupertinoIcon;

  final _NavDestination? destination;
  final String? _labelOverride;
  final IconData? _materialIconOverride;
  final IconData? _cupertinoIconOverride;

  bool matches(final String location) =>
      destination?.matches(location) ?? false;

  String get label => switch ((destination?.label, _labelOverride)) {
    (final destLabel?, _) => destLabel,
    (_, final labelOverride?) => labelOverride,
    _ => throw StateError('_NavItem: destination or label override required'),
  };
  IconData get materialIcon => switch ((
    destination?.materialIcon,
    _materialIconOverride,
  )) {
    (final destIcon?, _) => destIcon,
    (_, final iconOverride?) => iconOverride,
    _ => throw StateError(
      '_NavItem: destination or materialIcon override required',
    ),
  };
  IconData get cupertinoIcon => switch ((
    destination?.cupertinoIcon,
    _cupertinoIconOverride,
  )) {
    (final destIcon?, _) => destIcon,
    (_, final iconOverride?) => iconOverride,
    _ => throw StateError(
      '_NavItem: destination or cupertinoIcon override required',
    ),
  };
}

const int _profileTabIndex = 0;

const List<_NavItem> _navItems = <_NavItem>[
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

int _resolveSelectedIndex(final String currentLocation) {
  final int selectedIndex = _navItems.indexWhere(
    (final item) => item.matches(currentLocation),
  );
  return selectedIndex >= 0 ? selectedIndex : _profileTabIndex;
}

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

Future<void> _handleTap(
  final BuildContext context,
  final _NavItem item,
  final String currentLocation,
) async {
  final _NavDestination? destination = item.destination;
  if (destination == null) {
    await _pushRoute(
      context,
      AppRoutes.registerPath,
      logContext: 'ProfileBottomNav._handleTap.action',
    );
    return;
  }

  if (destination.route == AppRoutes.profilePath) {
    return;
  }

  if (destination.matches(currentLocation)) {
    return;
  }

  if (destination.route == AppRoutes.examplePath) {
    _goToExample(context);
    return;
  }

  await _pushRoute(
    context,
    destination.route,
    logContext: 'ProfileBottomNav._handleTap.navigate',
  );
}

void _goToExample(final BuildContext context) {
  if (!_ensureMounted(context, 'ProfileBottomNav._handleTap.example')) {
    return;
  }
  if (!NavigationUtils.maybePop(context)) {
    context.go(AppRoutes.examplePath);
  }
}

Future<void> _pushRoute(
  final BuildContext context,
  final String route, {
  required final String logContext,
}) async {
  if (!_ensureMounted(context, logContext)) {
    return;
  }
  await context.push(route);
}

bool _ensureMounted(final BuildContext context, final String logContext) {
  if (context.mounted) {
    return true;
  }
  ContextUtils.logNotMounted(logContext);
  return false;
}
