import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_role.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
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

List<_NavDestination> _baseDestinations(final AppLocalizations l10n) =>
    <_NavDestination>[
      _NavDestination(
        materialIcon: Icons.home_outlined,
        cupertinoIcon: CupertinoIcons.home,
        label: l10n.staffDemoNavHome,
        route: AppRoutes.staffAppDemoDashboardPath,
      ),
      _NavDestination(
        materialIcon: Icons.access_time,
        cupertinoIcon: CupertinoIcons.time,
        label: l10n.staffDemoNavTime,
        route: AppRoutes.staffAppDemoTimeclockPath,
      ),
      _NavDestination(
        materialIcon: Icons.message_outlined,
        cupertinoIcon: CupertinoIcons.chat_bubble_2,
        label: l10n.staffDemoNavMsgs,
        route: AppRoutes.staffAppDemoMessagesPath,
      ),
      _NavDestination(
        materialIcon: Icons.video_library_outlined,
        cupertinoIcon: CupertinoIcons.play_rectangle,
        label: l10n.staffDemoNavContent,
        route: AppRoutes.staffAppDemoContentPath,
      ),
      _NavDestination(
        materialIcon: Icons.assignment_outlined,
        cupertinoIcon: CupertinoIcons.square_list,
        label: l10n.staffDemoNavForms,
        route: AppRoutes.staffAppDemoFormsPath,
      ),
      _NavDestination(
        materialIcon: Icons.photo_camera_outlined,
        cupertinoIcon: CupertinoIcons.camera,
        label: l10n.staffDemoNavProof,
        route: AppRoutes.staffAppDemoProofPath,
      ),
    ];

_NavDestination _adminDestination(final AppLocalizations l10n) =>
    _NavDestination(
      materialIcon: Icons.admin_panel_settings_outlined,
      cupertinoIcon: CupertinoIcons.gear_alt,
      label: l10n.staffDemoNavAdmin,
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

  List<_NavDestination> _destinationsForRole(
    final AppLocalizations l10n,
    final StaffDemoRole? role,
  ) {
    final base = _baseDestinations(l10n);
    if (role == StaffDemoRole.manager || role == StaffDemoRole.accountant) {
      return <_NavDestination>[...base, _adminDestination(l10n)];
    }
    return base;
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final role = context.select<StaffDemoSessionCubit, StaffDemoRole?>(
      (final c) => c.state.profile?.role,
    );
    final destinations = _destinationsForRole(l10n, role);
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
