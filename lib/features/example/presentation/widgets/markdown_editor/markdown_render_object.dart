import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/markdown_editor/markdown_parser.dart';

/// Custom RenderObject for rendering markdown text with syntax highlighting.
///
/// This RenderObject:
/// - Handles text layout and measurement
/// - Renders markdown syntax (headers, bold, italic, code blocks)
/// - Supports scrolling and text selection
/// - Uses low-level painting for performance
class MarkdownRenderObject extends RenderBox {
  MarkdownRenderObject({
    required String text,
    required TextStyle textStyle,
    required this.onTextChanged,
    required TextDirection textDirection,
    EdgeInsets padding = EdgeInsets.zero,
  }) : _text = text,
       _textStyle = textStyle,
       _textDirection = textDirection,
       _padding = padding;

  String _text;
  TextStyle _textStyle;
  final ValueChanged<String> onTextChanged;
  EdgeInsets _padding;
  TextDirection _textDirection;

  String get text => _text;
  set text(final String value) {
    if (_text == value) return;
    _text = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  TextStyle get textStyle => _textStyle;
  set textStyle(final TextStyle value) {
    if (_textStyle == value) return;
    _textStyle = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  EdgeInsets get padding => _padding;
  set padding(final EdgeInsets value) {
    if (_padding == value) return;
    _padding = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  TextDirection get textDirection => _textDirection;
  set textDirection(final TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  final MarkdownParser _parser = MarkdownParser();
  TextPainter? _textPainter;

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final double availableWidth = constraints.maxWidth.isFinite
        ? (constraints.maxWidth - _padding.horizontal).clamp(0, double.infinity)
        : double.infinity;

    _layoutText(availableWidth);

    final TextPainter painter = _obtainTextPainter();
    final Size textSize = painter.size;
    final double width = constraints.constrainWidth(
      textSize.width + _padding.horizontal,
    );

    // Handle unbounded height (inside scroll view)
    final double height = constraints.maxHeight.isFinite
        ? constraints.constrainHeight(textSize.height + _padding.vertical)
        : textSize.height + _padding.vertical;

    size = Size(width, height);
  }

  @override
  bool get sizedByParent => false;

  @override
  double computeMinIntrinsicWidth(final double height) {
    _layoutText(double.infinity);
    return _obtainTextPainter().size.width + _padding.horizontal;
  }

  @override
  double computeMaxIntrinsicWidth(final double height) {
    _layoutText(double.infinity);
    return _obtainTextPainter().size.width + _padding.horizontal;
  }

  @override
  double computeMinIntrinsicHeight(final double width) {
    final double availableWidth = width.isFinite
        ? (width - _padding.horizontal).clamp(0, double.infinity)
        : double.infinity;
    _layoutText(availableWidth);
    return _obtainTextPainter().size.height + _padding.vertical;
  }

  @override
  double computeMaxIntrinsicHeight(final double width) {
    final double availableWidth = width.isFinite
        ? (width - _padding.horizontal).clamp(0, double.infinity)
        : double.infinity;
    _layoutText(availableWidth);
    return _obtainTextPainter().size.height + _padding.vertical;
  }

  TextPainter _obtainTextPainter() =>
      _textPainter ??= TextPainter(textDirection: _textDirection);

  void _layoutText(final double maxWidth) {
    final double effectiveMaxWidth = maxWidth.isFinite && maxWidth > 0
        ? maxWidth
        : double.infinity;
    final TextPainter painter = _obtainTextPainter()
      ..textDirection = _textDirection;

    if (_text.isEmpty) {
      painter
        ..text = const TextSpan(text: '')
        ..layout(maxWidth: effectiveMaxWidth);
      return;
    }

    painter
      ..text = _buildTextSpan()
      ..layout(maxWidth: effectiveMaxWidth);
  }

  TextSpan _buildTextSpan() => _parser.buildTextSpan(_text, _textStyle);

  @override
  void paint(final PaintingContext context, final Offset offset) {
    final TextPainter? painter = _textPainter;
    if (painter == null || painter.text == null) return;

    context.canvas.save();
    context.canvas.translate(
      offset.dx + _padding.left,
      offset.dy + _padding.top,
    );

    painter.paint(context.canvas, Offset.zero);

    context.canvas.restore();
  }

  @override
  bool hitTestSelf(final Offset position) => true;

  @override
  void dispose() {
    _textPainter?.dispose();
    _textPainter = null;
    super.dispose();
  }
}
