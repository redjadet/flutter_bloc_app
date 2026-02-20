import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:go_router/go_router.dart';

class LoggedOutActionButtons extends StatelessWidget {
  const LoggedOutActionButtons({
    required this.scale,
    required this.verticalScale,
    super.key,
  });

  final double scale;
  final double verticalScale;

  @override
  Widget build(final BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String signInLabel = context.l10n.accountSignInButton.toUpperCase();
    final String registerLabel = context.l10n.registerTitle.toUpperCase();
    return SizedBox(
      height: 52 * verticalScale,
      child: Row(
        children: [
          Expanded(
            child: _LoggedOutActionButton(
              label: signInLabel,
              scale: scale,
              backgroundColor: colors.surface,
              foregroundColor: colors.onSurface,
              border: BorderSide(width: 2, color: colors.outline),
              onPressed: () => context.go(AppRoutes.authPath),
            ),
          ),
          SizedBox(width: 9 * scale),
          Expanded(
            child: _LoggedOutActionButton(
              label: registerLabel,
              scale: scale,
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              onPressed: () => context.go(AppRoutes.registerPath),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoggedOutActionButton extends StatelessWidget {
  const _LoggedOutActionButton({
    required this.label,
    required this.scale,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.border,
  });

  final String label;
  final double scale;
  final Color backgroundColor;
  final Color foregroundColor;
  final BorderSide? border;
  final VoidCallback onPressed;

  @override
  Widget build(final BuildContext context) => SizedBox(
    height: double.infinity,
    child: border != null
        ? PlatformAdaptive.outlinedButton(
            context: context,
            onPressed: onPressed,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            side: border,
            borderRadius: BorderRadius.circular(6 * scale),
            materialStyle: OutlinedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              side: border,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6 * scale),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.52 * scale,
                height: 15.234 / 13,
              ),
            ),
          )
        : PlatformAdaptive.button(
            context: context,
            onPressed: onPressed,
            color: backgroundColor,
            materialStyle: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6 * scale),
              ),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.52 * scale,
                height: 15.234 / 13,
                color: foregroundColor,
              ),
            ),
          ),
  );
}
