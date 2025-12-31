import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
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
      action: onRetry == null
          ? null
          : CommonRetryButton(
              onPressed: onRetry!,
              label: context.l10n.retryButtonLabel,
            ),
    );
  }
}

/// A reusable retry button with consistent styling
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.responsiveCardRadius),
          border: Border.all(
            color: colors.outline,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(context.responsiveCardRadius),
            onTap: onPressed,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
