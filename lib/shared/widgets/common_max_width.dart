import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Constrains content to the shared max width and centers it.
class CommonMaxWidth extends StatelessWidget {
  const CommonMaxWidth({
    required this.child,
    super.key,
    this.maxWidth,
    this.alignment = Alignment.topCenter,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final Alignment alignment;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(final BuildContext context) {
    final Widget constrained = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? context.contentMaxWidth,
      ),
      child: child,
    );

    final Widget padded = padding == null
        ? constrained
        : Padding(
            padding: padding!,
            child: constrained,
          );

    return Align(
      alignment: alignment,
      child: padded,
    );
  }
}
