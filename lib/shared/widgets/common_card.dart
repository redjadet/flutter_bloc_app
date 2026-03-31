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

  @override
  Widget build(final BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Map<MixToken<dynamic>, Object>? tokens = MixScope.maybeOf(
      context,
      'tokens',
    )?.tokens;

    T? tokenOrNull<T>(final MixToken<T> token) {
      final Object? value = tokens?[token];
      return value is T ? value : null;
    }

    final Radius defaultRadius =
        tokenOrNull(AppMixTokens.radiusM) ?? Radius.circular(UI.radiusM);

    final EdgeInsetsGeometry effectivePadding =
        padding ??
        EdgeInsets.only(
          top: tokenOrNull(AppMixTokens.cardPadV) ?? UI.cardPadV,
          bottom: tokenOrNull(AppMixTokens.cardPadV) ?? UI.cardPadV,
          left: tokenOrNull(AppMixTokens.cardPadH) ?? UI.cardPadH,
          right: tokenOrNull(AppMixTokens.cardPadH) ?? UI.cardPadH,
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
