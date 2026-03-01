import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Listenable wrapper around an auth stream for GoRouter refreshes.
///
/// **Why this exists:** GoRouter's `refreshListenable` requires a `ChangeNotifier`,
/// but Firebase Auth provides a `Stream`. This adapter bridges the gap by listening
/// to auth state changes and notifying GoRouter to refresh routes (e.g., when user
/// logs in/out, routes need to update to show/hide protected routes).
///
/// **Usage Example:**
/// ```dart
/// final authRefresh = GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges());
/// return GoRouter(
///   refreshListenable: authRefresh,
///   routes: routes,
/// );
/// ```
///
/// **Lifecycle:** Must be disposed when the router is disposed to prevent memory leaks.
/// The subscription cancellation uses `unawaited()` because disposal is synchronous
/// and we don't need to wait for the cancellation to complete.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(final Stream<dynamic> stream) {
    _subscription = stream.listen(
      (_) => notifyListeners(),
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'GoRouterRefreshStream auth state error',
          error,
          stackTrace,
        );
      },
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
