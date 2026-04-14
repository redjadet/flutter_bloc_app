import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:go_router/go_router.dart';

/// Web-safe placeholder routes for the staff app demo.
///
/// The full staff app demo uses platform/file-store surfaces that are not part
/// of the minimal GitHub Pages readiness scope.
Widget _buildStaffAppDemoWebPlaceholder() => const CommonPageLayout(
  title: 'Staff app demo',
  body: Center(
    child: Text('Staff app demo is not available on web in this build.'),
  ),
);

ShellRoute createStaffAppDemoShellRoute() => ShellRoute(
  builder: (context, state, child) => child,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.staffAppDemoPath,
      name: AppRoutes.staffAppDemo,
      redirect: (context, state) => AppRoutes.staffAppDemoDashboardPath,
    ),
    GoRoute(
      path: AppRoutes.staffAppDemoDashboardPath,
      name: AppRoutes.staffAppDemoDashboard,
      builder: (context, state) => _buildStaffAppDemoWebPlaceholder(),
    ),
    GoRoute(
      path: AppRoutes.staffAppDemoTimeclockPath,
      name: AppRoutes.staffAppDemoTimeclock,
      builder: (context, state) => _buildStaffAppDemoWebPlaceholder(),
    ),
    GoRoute(
      path: AppRoutes.staffAppDemoMessagesPath,
      name: AppRoutes.staffAppDemoMessages,
      builder: (context, state) => _buildStaffAppDemoWebPlaceholder(),
    ),
    GoRoute(
      path: AppRoutes.staffAppDemoContentPath,
      name: AppRoutes.staffAppDemoContent,
      builder: (context, state) => _buildStaffAppDemoWebPlaceholder(),
    ),
    GoRoute(
      path: AppRoutes.staffAppDemoFormsPath,
      name: AppRoutes.staffAppDemoForms,
      builder: (context, state) => _buildStaffAppDemoWebPlaceholder(),
    ),
    GoRoute(
      path: AppRoutes.staffAppDemoProofPath,
      name: AppRoutes.staffAppDemoProof,
      builder: (context, state) => _buildStaffAppDemoWebPlaceholder(),
    ),
    GoRoute(
      path: AppRoutes.staffAppDemoAdminPath,
      name: AppRoutes.staffAppDemoAdmin,
      builder: (context, state) => _buildStaffAppDemoWebPlaceholder(),
    ),
  ],
);
