import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';

/// Builds the swipe background widget for dismissible todo items.
Widget buildTodoSwipeBackground({
  required final BuildContext context,
  required final Alignment alignment,
  required final Color color,
  required final Color foregroundColor,
  required final IconData icon,
  required final String label,
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
        Text(
          label,
          style: TextStyle(
            color: foregroundColor,
            fontSize: context.responsiveBodySize,
            fontWeight: FontWeight.w600,
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
