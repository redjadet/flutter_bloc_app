import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

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

TextStyle profileButtonTextStyle({
  required final Color color,
  required final double fontSize,
}) => GoogleFonts.roboto(
  fontSize: fontSize,
  fontWeight: FontWeight.w900,
  letterSpacing: 0.52,
  color: color,
  height: 15.234375 / 13,
);
