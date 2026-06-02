part of 'profile_bottom_nav.dart';

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
