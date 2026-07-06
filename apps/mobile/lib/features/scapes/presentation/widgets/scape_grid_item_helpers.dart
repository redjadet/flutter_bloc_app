import 'package:design_system/responsive.dart';
import 'package:flutter/material.dart';

/// Fits a title style to ensure text doesn't overflow the given width.
///
/// Iteratively reduces font size until the text fits within [maxWidth].
TextStyle fitTitleStyle({
  required final TextStyle baseStyle,
  required final String text,
  required final double maxWidth,
  required final TextScaler textScaler,
  required final TextDirection textDirection,
}) {
  final double baseSize = baseStyle.fontSize ?? UI.scaleFontMax(18);
  final double minSize = UI.scaleFontMax(13);
  double fontSize = baseSize;

  while (fontSize > minSize) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: baseStyle.copyWith(fontSize: fontSize),
      ),
      maxLines: 1,
      textScaler: textScaler,
      textDirection: textDirection,
    )..layout(maxWidth: maxWidth);

    if (!painter.didExceedMaxLines) {
      break;
    }
    fontSize -= 0.5;
  }

  return baseStyle.copyWith(fontSize: fontSize);
}
