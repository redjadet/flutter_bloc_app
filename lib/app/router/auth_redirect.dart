import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:go_router/go_router.dart';

/// Creates an authentication redirect function for GoRouter.
///
/// **Authentication Redirect Logic:**
/// 1. Checks if user is logged in via `FirebaseAuth.currentUser`
/// 2. Allows deep link navigation to proceed without redirect (for universal links)
/// 3. Redirects unauthenticated users to `/auth` (except when already on auth page)
/// 4. Redirects authenticated users away from `/auth` to `/counter` (unless upgrading anonymous account)
///
/// **Deep Link Handling:**
/// Deep links (any route other than `/` or `/counter` or `/auth`) are allowed
/// to proceed even when the user is not authenticated. This enables universal links
/// and custom scheme deep links to work seamlessly.
///
/// **Anonymous Account Upgrading:**
/// When an anonymous user is on the auth page, they're allowed to stay there
/// to upgrade their account. Once authenticated, they're redirected to `/counter`.
GoRouterRedirect createAuthRedirect(final FirebaseAuth auth) =>
    (final context, final state) {
      final bool loggedIn = auth.currentUser != null;
      final bool loggingIn = state.matchedLocation == AppRoutes.authPath;

      // Deep link detection: Allow navigation to any route other than
      // root paths (/counter, /auth, /) to proceed without authentication.
      // This enables universal links and custom scheme deep links to work
      // seamlessly, allowing users to access specific features via links.
      final String currentLocation = state.matchedLocation;
      final bool isDeepLinkNavigation =
          currentLocation != AppRoutes.counterPath &&
          currentLocation != AppRoutes.authPath &&
          currentLocation != '/';

      // Unauthenticated user flow
      if (!loggedIn) {
        // Allow deep links to proceed (e.g., /profile, /chat, /graphql)
        // This enables universal links to work without requiring login first
        if (isDeepLinkNavigation) {
          return null; // Allow navigation to proceed
        }
        // Redirect to auth page unless already there
        return loggingIn ? null : AppRoutes.authPath;
      }

      // Authenticated user flow
      if (loggingIn) {
        // Allow anonymous users to stay on auth page to upgrade their account
        final bool upgradingAnonymous = auth.currentUser?.isAnonymous ?? false;
        if (upgradingAnonymous) {
          return null; // Stay on auth page to complete upgrade
        }
        // Redirect authenticated users away from auth page to counter
        return AppRoutes.counterPath;
      }

      // No redirect needed - allow navigation to proceed
      return null;
    };
