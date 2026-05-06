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

  static const AppRoutePolicy settings = AppRoutePolicy(
    path: AppRoutes.settingsPath,
    requirement: RouteAuthRequirement.authenticated,
  );

  static const AppRoutePolicy profile = AppRoutePolicy(
    path: AppRoutes.profilePath,
    requirement: RouteAuthRequirement.authenticated,
  );

  static const AppRoutePolicy manageAccount = AppRoutePolicy(
    path: AppRoutes.manageAccountPath,
    requirement: RouteAuthRequirement.authenticated,
  );

  static const AppRoutePolicy onlineTherapyDemoAdmin = AppRoutePolicy(
    path: AppRoutes.onlineTherapyDemoAdminPath,
    requirement: RouteAuthRequirement.authenticated,
  );

  static const AppRoutePolicy onlineTherapyDemoAdminVerification =
      AppRoutePolicy(
        path: AppRoutes.onlineTherapyDemoAdminVerificationPath,
        requirement: RouteAuthRequirement.authenticated,
      );

  static const AppRoutePolicy onlineTherapyDemoAdminAudit = AppRoutePolicy(
    path: AppRoutes.onlineTherapyDemoAdminAuditPath,
    requirement: RouteAuthRequirement.authenticated,
  );

  static const AppRoutePolicy walletconnectAuth = AppRoutePolicy(
    path: AppRoutes.walletconnectAuthPath,
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
