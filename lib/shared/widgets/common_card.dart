import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:mix/mix.dart';

/// A reusable Card widget with standard padding and responsive design.
///
/// Defaults are derived from the same Mix tokens used by [AppStyles.card],
/// keeping padding, radius, and colors consistent and theme-aware. Optional
/// parameters override the default style when provided.
class CommonCard extends StatelessWidget {
  const CommonCard({
    required this.child,
    super.key,
    this.color,
    this.elevation,
    this.margin,
    this.shape,
    this.padding,
  });

  final Widget child;
  final Color? color;
  final double? elevation;
  final EdgeInsetsGeometry? margin;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? padding;

  T? _maybeToken<T>(final MixToken<T> token, final BuildContext context) {
    final scope = MixScope.maybeOf(context, 'tokens');
    if (scope == null) {
      return null;
    }
    try {
      return MixScope.tokenOf(token, context);
    } on Exception {
      return null;
    }
  }

  @override
  Widget build(final BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Radius defaultRadius =
        _maybeToken(AppMixTokens.radiusM, context) ??
        Radius.circular(UI.radiusM);

    final EdgeInsetsGeometry effectivePadding =
        padding ??
        EdgeInsets.only(
          top: _maybeToken(AppMixTokens.cardPadV, context) ?? UI.cardPadV,
          bottom: _maybeToken(AppMixTokens.cardPadV, context) ?? UI.cardPadV,
          left: _maybeToken(AppMixTokens.cardPadH, context) ?? UI.cardPadH,
          right: _maybeToken(AppMixTokens.cardPadH, context) ?? UI.cardPadH,
        );
    final ShapeBorder effectiveShape =
        shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(defaultRadius),
        );

    return Card(
      color: color ?? colors.surface,
      elevation: elevation ?? 1,
      margin: margin,
      shape: effectiveShape,
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );
  }
}
