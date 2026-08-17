import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/utils/context_utils.dart';
import 'package:go_router/go_router.dart';

/// Navigation helpers shared across presentation layer widgets.
class NavigationUtils {
  const NavigationUtils._();

  /// Attempts to pop the current route.
  /// Returns true if a route was popped, false otherwise.
  static bool maybePop(
    BuildContext context, {
    Object? result,
    bool useRootNavigator = false,
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
  static void popOrGoHome(BuildContext context) {
    final bool didPop = maybePop(context);
    if (!didPop) {
      context.go(AppRoutes.counterPath);
    }
  }

  /// Safely navigates using [GoRouter.go] after ensuring the [context] is still mounted.
  ///
  /// Useful for delayed navigation flows (e.g. deep links) where the caller might
  /// no longer be active by the time navigation occurs.
  static Future<void> safeGo(
    BuildContext context, {
    required GoRouter router,
    required String location,
    Duration delay = const Duration(milliseconds: 100),
    String logContext = 'NavigationUtils.safeGo',
    VoidCallback? onSkipped,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (!context.mounted) {
      ContextUtils.logNotMounted(logContext);
      onSkipped?.call();
      return;
    }
    try {
      router.go(location);
    } on Exception catch (error, stackTrace) {
      AppLogger.error('$logContext failed', error, stackTrace);
    }
  }
}
