import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// A compact row of an optional icon, gap, and a single-line ellipsed label.
/// Use for buttons and toolbar items to avoid RenderFlex overflow on narrow
/// widths.
class IconLabelRow extends StatelessWidget {
  const IconLabelRow({
    required this.label,
    super.key,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.textStyle,
    this.trailing,
  });

  final String label;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final TextStyle? textStyle;
  final Widget? trailing;

  @override
  Widget build(final BuildContext context) {
    final gap = context.responsiveHorizontalGapS;
    final effectiveIconSize = iconSize ?? context.responsiveIconSize;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon case final iconData?) ...[
          Icon(
            iconData,
            size: effectiveIconSize,
            color: iconColor,
          ),
          SizedBox(width: gap),
        ],
        Flexible(
          child: Text(
            label,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (trailing case final trailingWidget?) ...[
          SizedBox(width: gap / 2),
          trailingWidget,
        ],
      ],
    );
  }
}
