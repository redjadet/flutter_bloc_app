import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

/// A reusable loading widget with consistent styling
class CommonLoadingWidget extends StatelessWidget {
  const CommonLoadingWidget({
    super.key,
    this.message,
    this.size = 24.0,
    this.color,
  });

  final String? message;
  final double size;
  final Color? color;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.secondary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: effectiveColor,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: UI.gapM),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// A reusable loading overlay that can be placed over content
class CommonLoadingOverlay extends StatelessWidget {
  const CommonLoadingOverlay({
    required this.isLoading,
    required this.child,
    super.key,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(final BuildContext context) => Stack(
    children: [
      child,
      if (isLoading)
        ColoredBox(
          color: Colors.black.withValues(alpha: 0.3),
          child: CommonLoadingWidget(message: message),
        ),
    ],
  );
}

/// A reusable loading button that shows progress when loading
class CommonLoadingButton extends StatelessWidget {
  const CommonLoadingButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.isLoading = false,
    this.loadingMessage,
    this.style,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final ButtonStyle? style;

  @override
  Widget build(final BuildContext context) => ElevatedButton(
    onPressed: isLoading ? null : onPressed,
    style: style,
    child: isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              if (loadingMessage != null) ...[
                SizedBox(width: context.responsiveHorizontalGapS),
                Text(loadingMessage!),
              ],
            ],
          )
        : child,
  );
}
