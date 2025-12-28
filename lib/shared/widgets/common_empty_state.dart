import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_status_view.dart';

/// A reusable empty state widget with consistent styling and optional actions.
///
/// Provides a standard pattern for displaying empty states across features
/// with icon, title, message, and optional primary action button.
class CommonEmptyState extends StatelessWidget {
  const CommonEmptyState({
    required this.message,
    super.key,
    this.icon,
    this.title,
    this.primaryAction,
    this.primaryActionLabel,
  });

  /// The main message to display.
  final String message;

  /// Optional icon to display above the message.
  final IconData? icon;

  /// Optional title to display above the message.
  final String? title;

  /// Optional primary action callback.
  final VoidCallback? primaryAction;

  /// Optional label for the primary action button.
  /// If not provided and [primaryAction] is set, defaults to 'Try Again'.
  final String? primaryActionLabel;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return CommonStatusView(
      message: message,
      title: title,
      icon: icon,
      iconSize: context.responsiveIconSize * 2.5,
      iconColor: colors.onSurface.withValues(alpha: 0.6),
      titleStyle: theme.textTheme.titleLarge?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      messageStyle: theme.textTheme.bodyLarge?.copyWith(
        color: colors.onSurface.withValues(alpha: 0.7),
      ),
      action: primaryAction == null
          ? null
          : PlatformAdaptive.filledButton(
              context: context,
              onPressed: primaryAction,
              child: Text(primaryActionLabel ?? 'Try Again'),
            ),
      semanticsLabel: 'Empty state: $message',
    );
  }
}
