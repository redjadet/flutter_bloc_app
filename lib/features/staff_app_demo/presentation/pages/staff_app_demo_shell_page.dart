import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_role.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:go_router/go_router.dart';

class StaffAppDemoShellPage extends StatelessWidget {
  const StaffAppDemoShellPage({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final double bottomPadding = context.safeAreaInsets.bottom;
    final ThemeData theme = Theme.of(context);
    final bool useCupertino = PlatformAdaptive.isCupertinoFromTheme(theme);
    final String currentLocation = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.toString();

    return Scaffold(
      body: child,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: _StaffDemoBottomNav(
          currentLocation: currentLocation,
          useCupertino: useCupertino,
        ),
      ),
    );
  }
}

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

const _NavDestination _dashboard = _NavDestination(
  materialIcon: Icons.home_outlined,
  cupertinoIcon: CupertinoIcons.home,
  label: 'Home',
  route: AppRoutes.staffAppDemoDashboardPath,
);
const _NavDestination _timeclock = _NavDestination(
  materialIcon: Icons.access_time,
  cupertinoIcon: CupertinoIcons.time,
  label: 'Time',
  route: AppRoutes.staffAppDemoTimeclockPath,
);
const _NavDestination _messages = _NavDestination(
  materialIcon: Icons.message_outlined,
  cupertinoIcon: CupertinoIcons.chat_bubble_2,
  label: 'Msgs',
  route: AppRoutes.staffAppDemoMessagesPath,
);
const _NavDestination _content = _NavDestination(
  materialIcon: Icons.video_library_outlined,
  cupertinoIcon: CupertinoIcons.play_rectangle,
  label: 'Content',
  route: AppRoutes.staffAppDemoContentPath,
);
const _NavDestination _forms = _NavDestination(
  materialIcon: Icons.assignment_outlined,
  cupertinoIcon: CupertinoIcons.square_list,
  label: 'Forms',
  route: AppRoutes.staffAppDemoFormsPath,
);
const _NavDestination _proof = _NavDestination(
  materialIcon: Icons.photo_camera_outlined,
  cupertinoIcon: CupertinoIcons.camera,
  label: 'Proof',
  route: AppRoutes.staffAppDemoProofPath,
);
const _NavDestination _admin = _NavDestination(
  materialIcon: Icons.admin_panel_settings_outlined,
  cupertinoIcon: CupertinoIcons.gear_alt,
  label: 'Admin',
  route: AppRoutes.staffAppDemoAdminPath,
);

int _resolveSelectedIndex(
  final String currentLocation,
  final List<_NavDestination> destinations,
) {
  final int selectedIndex = destinations.indexWhere(
    (final d) => d.matches(currentLocation),
  );
  return selectedIndex >= 0 ? selectedIndex : 0;
}

class _StaffDemoBottomNav extends StatelessWidget {
  const _StaffDemoBottomNav({
    required this.currentLocation,
    required this.useCupertino,
  });

  final String currentLocation;
  final bool useCupertino;

  List<_NavDestination> _destinationsForRole(final StaffDemoRole? role) {
    final base = <_NavDestination>[
      _dashboard,
      _timeclock,
      _messages,
      _content,
      _forms,
      _proof,
    ];
    if (role == StaffDemoRole.manager || role == StaffDemoRole.accountant) {
      return <_NavDestination>[...base, _admin];
    }
    return base;
  }

  @override
  Widget build(final BuildContext context) {
    final role = context.select<StaffDemoSessionCubit, StaffDemoRole?>(
      (final c) => c.state.profile?.role,
    );
    final destinations = _destinationsForRole(role);
    final selectedIndex = _resolveSelectedIndex(currentLocation, destinations);

    final items = destinations
        .map(
          (final d) => BottomNavigationBarItem(
            icon: Icon(useCupertino ? d.cupertinoIcon : d.materialIcon),
            label: d.label,
          ),
        )
        .toList();

    Future<void> onTap(final int index) async {
      final dest = destinations[index];
      if (dest.matches(currentLocation)) return;
      context.go(dest.route);
    }

    if (useCupertino) {
      return CupertinoTabBar(
        currentIndex: selectedIndex,
        items: items,
        onTap: (final index) => onTap(index),
      );
    }
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      items: items,
      onTap: (final index) => onTap(index),
    );
  }
}
