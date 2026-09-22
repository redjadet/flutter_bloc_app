import 'package:flutter_bloc_app/app/router/app_routes.dart';

/// Declarative auth requirement for a path.
///
/// `createAuthRedirect` is a coarse deep-link-friendly guard; this table (and
/// route-level gates that read it) owns which destinations require a signed-in
/// user after navigation lands.
enum RouteAuthRequirement { publicRoute, authenticated }

class const AppRoutePolicy({
  required final String path,
  required final RouteAuthRequirement requirement,
}) {
  bool get requiresAuthentication =>
      requirement == RouteAuthRequirement.authenticated;
}

/// Known route auth policies used by gates and reviews.
class AppRoutePolicies {
  new _();

  static const AppRoutePolicy settings = AppRoutePolicy(
    path: AppRoutes.settingsPath,
    requirement: RouteAuthRequirement.publicRoute,
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
