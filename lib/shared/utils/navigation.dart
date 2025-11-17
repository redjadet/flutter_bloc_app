import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

/// Navigation helpers shared across presentation layer widgets.
class NavigationUtils {
  const NavigationUtils._();

  /// Attempts to pop the current route.
  /// Returns true if a route was popped, false otherwise.
  static bool maybePop(
    final BuildContext context, {
    final Object? result,
    final bool useRootNavigator = false,
  }) {
    final NavigatorState navigator = Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    );
    if (!navigator.canPop()) {
      return false;
    }
    navigator.pop(result);
    return true;
  }

  /// Pops the current route when possible, otherwise navigates to the home route.
  static void popOrGoHome(final BuildContext context) {
    final bool didPop = maybePop(context);
    if (!didPop) {
      context.go(AppRoutes.counterPath);
    }
  }
}
