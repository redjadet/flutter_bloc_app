import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

/// Navigation helpers shared across presentation layer widgets.
class NavigationUtils {
  const NavigationUtils._();

  /// Pops the current route when possible, otherwise navigates to the home route.
  static void popOrGoHome(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    context.go(AppRoutes.counterPath);
  }
}
