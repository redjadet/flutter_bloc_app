import 'package:material_ui/material_ui.dart';

import '../../responsive.dart';

/// Compact icon + single-line ellipsed label.
///
/// `Row` does not shrink non-flex children (constraints stay loose on the
/// main axis). Wrapping [Text] in [Flexible] passes a finite max width
/// down so the label can ellipsize instead of overflowing. Prefer this over
/// raw `Row(Icon, Text)`. See `docs/architecture/flutter_layout_constraints.md`.
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
  Widget build(BuildContext context) {
    final gap = context.responsiveHorizontalGapS;
    final effectiveIconSize = iconSize ?? context.responsiveIconSize;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon case final iconData?) ...[
          Icon(iconData, size: effectiveIconSize, color: iconColor),
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
