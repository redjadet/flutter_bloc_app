import 'package:flutter_bloc_app/core/router/app_routes.dart';

enum RouteAuthRequirement {
  publicRoute,
  authenticated,
}

class AppRoutePolicy {
  const AppRoutePolicy({
    required this.path,
    required this.requirement,
  });

  final String path;
  final RouteAuthRequirement requirement;

  bool get requiresAuthentication =>
      requirement == RouteAuthRequirement.authenticated;
}

class AppRoutePolicies {
  AppRoutePolicies._();

  static const AppRoutePolicy profile = AppRoutePolicy(
    path: AppRoutes.profilePath,
    requirement: RouteAuthRequirement.authenticated,
  );

  static const AppRoutePolicy caseStudyDemo = AppRoutePolicy(
    path: AppRoutes.caseStudyDemoPath,
    requirement: RouteAuthRequirement.authenticated,
  );

  static const AppRoutePolicy staffAppDemo = AppRoutePolicy(
    path: AppRoutes.staffAppDemoPath,
    requirement: RouteAuthRequirement.authenticated,
  );
}
