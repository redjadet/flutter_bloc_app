import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/typography.dart';

ButtonStyle profileOutlinedButtonStyle(
  final BuildContext context, {
  required final Color backgroundColor,
}) => OutlinedButton.styleFrom(
  backgroundColor: backgroundColor,
  side: const BorderSide(width: 2),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(context.responsiveCardRadius),
  ),
  padding: EdgeInsets.zero,
);

TextStyle profileButtonTextStyle(
  final BuildContext context, {
  required final Color color,
  required final double fontSize,
}) => AppTypography.buttonText(
  context,
  fontWeight: FontWeight.w900,
  fontSize: fontSize,
  letterSpacing: 0.52,
  color: color,
  height: 15.234375 / 13,
);
