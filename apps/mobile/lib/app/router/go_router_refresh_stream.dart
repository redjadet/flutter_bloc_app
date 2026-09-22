import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter/widgets.dart';

/// Adapts any auth [Stream] into a [ChangeNotifier] for GoRouter refreshes.
///
/// GoRouter's `refreshListenable` needs a [Listenable]; repository auth APIs
/// expose streams. Subscribe once and call [notifyListeners] on each event.
/// GoRouter does **not** dispose an externally supplied listenable—the owner
/// (composition root / `MyApp`) must call [dispose] to cancel the subscription
/// (`unawaited` cancel is intentional; disposal is synchronous).
///
/// ```dart
/// final authRefresh = GoRouterRefreshStream(authRepository.authStateChanges);
/// final router = GoRouter(refreshListenable: authRefresh, routes: routes);
/// // Later, when tearing down the app graph:
/// authRefresh.dispose();
/// ```
class GoRouterRefreshStream extends ChangeNotifier {
  new(Stream<dynamic> stream) {
    _subscription = stream.listen(
      (_) => notifyListeners(),
      onError: (Object error, StackTrace stackTrace) {
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
