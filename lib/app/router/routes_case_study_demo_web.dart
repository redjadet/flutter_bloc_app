import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:go_router/go_router.dart';

/// Web-safe placeholder routes for the case study demo.
///
/// The full case study demo includes video/file storage flows that are not part
/// of the minimal GitHub Pages readiness scope.
Widget _buildCaseStudyDemoWebPlaceholder() => const CommonPageLayout(
  title: 'Case study demo',
  body: Center(
    child: Text('Case study demo is not available on web in this build.'),
  ),
);

ShellRoute createCaseStudyDemoShellRoute() => ShellRoute(
  builder: (context, state, child) => child,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.caseStudyDemoPath,
      name: AppRoutes.caseStudyDemo,
      builder: (context, state) => _buildCaseStudyDemoWebPlaceholder(),
    ),
    GoRoute(
      path: AppRoutes.caseStudyDemoNewPath,
      name: AppRoutes.caseStudyDemoNew,
      builder: (context, state) => _buildCaseStudyDemoWebPlaceholder(),
    ),
    GoRoute(
      path: AppRoutes.caseStudyDemoRecordPath,
      name: AppRoutes.caseStudyDemoRecord,
      builder: (context, state) => _buildCaseStudyDemoWebPlaceholder(),
    ),
    GoRoute(
      path: AppRoutes.caseStudyDemoReviewPath,
      name: AppRoutes.caseStudyDemoReview,
      builder: (context, state) => _buildCaseStudyDemoWebPlaceholder(),
    ),
    GoRoute(
      path: AppRoutes.caseStudyDemoHistoryPath,
      name: AppRoutes.caseStudyDemoHistory,
      builder: (context, state) => _buildCaseStudyDemoWebPlaceholder(),
      routes: <RouteBase>[
        GoRoute(
          path: ':id',
          name: AppRoutes.caseStudyDemoHistoryDetail,
          builder: (context, state) => _buildCaseStudyDemoWebPlaceholder(),
        ),
      ],
    ),
  ],
);
