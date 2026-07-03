import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/utils/context_utils.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
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

  /// Safely navigates using [GoRouter.go] after ensuring the [context] is still mounted.
  ///
  /// Useful for delayed navigation flows (e.g. deep links) where the caller might
  /// no longer be active by the time navigation occurs.
  static Future<void> safeGo(
    final BuildContext context, {
    required final GoRouter router,
    required final String location,
    final Duration delay = const Duration(milliseconds: 100),
    final String logContext = 'NavigationUtils.safeGo',
    final VoidCallback? onSkipped,
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
