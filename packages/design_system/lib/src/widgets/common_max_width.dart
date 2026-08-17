import 'package:design_system/responsive.dart';
import 'package:material_ui/material_ui.dart';

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
  Widget build(BuildContext context) {
    final Widget constrained = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? context.contentMaxWidth,
      ),
      child: child,
    );

    final Widget padded = switch (padding) {
      final p? => Padding(padding: p, child: constrained),
      _ => constrained,
    };

    return Align(alignment: alignment, child: padded);
  }
}
