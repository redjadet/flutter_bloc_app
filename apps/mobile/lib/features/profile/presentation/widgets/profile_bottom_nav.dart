import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/utils/context_utils.dart';
import 'package:flutter_bloc_app/app/utils/navigation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

part 'profile_bottom_nav_handlers.part.dart';
part 'profile_bottom_nav_models.part.dart';

class ProfileBottomNav extends StatelessWidget {
  const ProfileBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
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
        (item) => BottomNavigationBarItem(
          icon: Icon(useCupertino ? item.cupertinoIcon : item.materialIcon),
          label: item.label,
        ),
      )
      .toList();

  Future<void> _onTap(BuildContext context, int index) =>
      _handleTap(context, items[index], currentLocation);

  @override
  Widget build(BuildContext context) {
    if (useCupertino) {
      return CupertinoTabBar(
        currentIndex: selectedIndex,
        items: _navigationBarItems,
        onTap: (index) => _onTap(context, index),
      );
    }
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: (index) => _onTap(context, index),
      items: _navigationBarItems,
    );
  }
}
