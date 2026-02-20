import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_status_view.dart';

/// A reusable error view widget with consistent styling
class CommonErrorView extends StatelessWidget {
  const CommonErrorView({
    required this.message,
    super.key,
    this.onRetry,
    this.icon,
    this.iconSize,
    this.iconColor,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final effectiveIcon = icon ?? Icons.error_outline;
    final effectiveIconSize = iconSize ?? context.responsiveErrorIconSize;
    final effectiveIconColor = iconColor ?? colors.onSurfaceVariant;

    return CommonStatusView(
      message: message,
      icon: effectiveIcon,
      iconSize: effectiveIconSize,
      iconColor: effectiveIconColor,
      messageStyle: TextStyle(
        fontSize: context.responsiveTitleSize,
        fontWeight: FontWeight.w600,
      ),
      action: switch (onRetry) {
        final cb? => CommonRetryButton(
          onPressed: cb,
          label: context.l10n.retryButtonLabel,
        ),
        _ => null,
      },
    );
  }
}

/// A reusable retry button with consistent styling
/// Uses platform-adaptive button styling (CupertinoButton on iOS, OutlinedButton on Android)
class CommonRetryButton extends StatelessWidget {
  const CommonRetryButton({
    required this.onPressed,
    required this.label,
    super.key,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SizedBox(
      height: context.responsiveButtonHeight,
      child: PlatformAdaptive.outlinedButton(
        context: context,
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        borderRadius: BorderRadius.circular(context.responsiveCardRadius),
        side: BorderSide(
          color: colors.outline,
          width: 1.5,
        ),
        materialStyle: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.responsiveCardRadius),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
