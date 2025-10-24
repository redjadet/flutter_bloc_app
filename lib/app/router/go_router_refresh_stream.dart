import 'dart:async';

import 'package:flutter/widgets.dart';

/// Listenable wrapper around an auth stream for GoRouter refreshes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(final Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
