import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter/widgets.dart';

/// Helpers for safely working with [BuildContext] across async boundaries.
class ContextUtils {
  const ContextUtils._();

  /// Returns `true` if the [context] is still mounted. Otherwise logs a debug
  /// message (when [debugLabel] is provided) and returns `false`.
  static bool ensureMounted(
    final BuildContext context, {
    final String? debugLabel,
  }) {
    if (context.mounted) {
      return true;
    }
    if (debugLabel != null) {
      logNotMounted(debugLabel);
    }
    return false;
  }

  static void logNotMounted(final String debugLabel) {
    AppLogger.debug(
      'Skipping $debugLabel — context is no longer mounted.',
    );
  }
}
