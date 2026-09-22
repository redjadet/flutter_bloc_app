import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:go_router/go_router.dart';

/// Creates an authentication redirect function for GoRouter.
///
/// Coarse navigation guard only—not authorization:
/// 1. Reads auth via [AuthRepository.currentUser].
/// 2. For unauthenticated users, every matched location except `/`, `/counter`,
///    and `/auth` proceeds without redirect (predicate is path-only—covers
///    in-app navigation and external links alike). **Protected destinations
///    still need `AppRoutePolicies` / route-level auth gates.**
/// 3. Sends unauthenticated users on `/`, `/counter`, or `/auth` to `/auth`.
/// 4. Sends authenticated users away from `/auth` to `/counter` unless
///    anonymous upgrade (`?upgrade=true`) or a safe `redirect` query is set.
GoRouterRedirect createAuthRedirect(AuthRepository auth) => (context, state) {
  final bool loggedIn = auth.currentUser != null;
  final bool loggingIn = state.matchedLocation == AppRoutes.authPath;
  final bool upgradeIntent =
      state.uri.queryParameters[AppRoutes.authUpgradeQueryKey] ==
      AppRoutes.authUpgradeQueryValue;
  final String? redirectAfterLogin = state.uri.queryParameters['redirect'];

  // Path allowlist for the coarse guard—not a claim about link origin.
  final String currentLocation = state.matchedLocation;
  final bool isNonRootPath =
      currentLocation != AppRoutes.counterPath &&
      currentLocation != AppRoutes.authPath &&
      currentLocation != '/';

  if (!loggedIn) {
    // Non-root paths proceed; route gates may still block protected destinations.
    if (isNonRootPath) {
      return null;
    }
    return loggingIn ? null : AppRoutes.authPath;
  }

  if (loggingIn) {
    final bool upgradingAnonymous = auth.currentUser?.isAnonymous ?? false;
    if (upgradingAnonymous && upgradeIntent) {
      return null;
    }
    if (AppRoutes.isSafeRedirectPath(redirectAfterLogin)) {
      return redirectAfterLogin;
    }
    return AppRoutes.counterPath;
  }

  return null;
};
