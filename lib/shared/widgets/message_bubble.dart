import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/markdown_editor/markdown_parser.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';

/// A reusable message bubble widget for chat-like interfaces
/// Supports markdown rendering for rich text formatting
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    required this.isOutgoing,
    super.key,
    this.maxWidth,
    this.margin,
    this.padding,
    this.borderRadius,
    this.outgoingColor,
    this.incomingColor,
    this.outgoingTextColor,
    this.incomingTextColor,
  });

  final String message;
  final bool isOutgoing;
  final double? maxWidth;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color? outgoingColor;
  final Color? incomingColor;
  final Color? outgoingTextColor;
  final Color? incomingTextColor;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final Alignment alignment = isOutgoing
        ? Alignment.centerRight
        : Alignment.centerLeft;

    final Color bubbleColor = isOutgoing
        ? (outgoingColor ?? colors.primary)
        : (incomingColor ?? colors.surfaceContainerHighest);

    final Color textColor = isOutgoing
        ? (outgoingTextColor ?? colors.onPrimary)
        : (incomingTextColor ?? colors.onSurface);

    final EdgeInsets effectiveMargin =
        margin ??
        (isOutgoing
            ? context.responsiveBubbleMargin
            : context.responsiveBubbleMargin);

    final EdgeInsets effectivePadding =
        padding ??
        (isOutgoing
            ? context.responsiveBubblePadding
            : context.responsiveBubblePadding);

    final double effectiveBorderRadius =
        borderRadius ?? context.responsiveCardRadius;

    final double effectiveMaxWidth = maxWidth ?? context.widthFraction(0.75);

    final TextStyle baseTextStyle =
        theme.textTheme.bodyMedium?.copyWith(color: textColor) ??
        TextStyle(color: textColor);

    final MarkdownParser markdownParser = MarkdownParser();
    final TextSpan textSpan = markdownParser.buildTextSpan(
      message,
      baseTextStyle,
    );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: CommonCard(
          margin: effectiveMargin,
          color: bubbleColor,
          elevation: 0,
          padding: effectivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
          ),
          child: RichText(
            text: textSpan,
            textScaler: MediaQuery.textScalerOf(context),
          ),
        ),
      ),
    );
  }
}
