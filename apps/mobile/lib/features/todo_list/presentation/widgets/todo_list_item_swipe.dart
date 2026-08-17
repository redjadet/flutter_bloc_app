import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the swipe background widget for dismissible todo items.
Widget buildTodoSwipeBackground({
  required BuildContext context,
  required AlignmentGeometry alignment,
  required Color color,
  required Color foregroundColor,
  required IconData icon,
  required String label,
}) => CommonCard(
  color: color,
  elevation: 0,
  margin: EdgeInsets.zero,
  padding: EdgeInsets.symmetric(
    horizontal: context.responsiveHorizontalGapL,
  ),
  child: Align(
    alignment: alignment,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foregroundColor,
              fontSize: context.responsiveBodySize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: context.responsiveHorizontalGapS),
        Icon(
          icon,
          color: foregroundColor,
          size: context.responsiveIconSize * 1.5,
        ),
      ],
    ),
  ),
);
