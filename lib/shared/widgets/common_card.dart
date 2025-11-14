import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// A reusable Card widget with standard padding and responsive design.
///
/// This widget eliminates the common pattern of wrapping Card with Padding
/// and provides consistent card styling across the app.
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
    final EdgeInsetsGeometry effectivePadding =
        padding ?? context.responsiveCardPaddingInsets;

    return Card(
      color: color,
      elevation: elevation,
      margin: margin,
      shape: shape,
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );
  }
}
