import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/markdown_editor/markdown_render_object.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

/// Preview component that renders markdown using a custom RenderObject.
class MarkdownPreview extends StatelessWidget {
  const MarkdownPreview({
    required this.text,
    super.key,
  });

  final String text;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(context.responsiveGapM),
      color: colors.surface,
      child: SingleChildScrollView(
        child: IntrinsicWidth(
          child: _MarkdownRenderObjectWidget(
            text: text,
            textStyle: theme.textTheme.bodyLarge!,
            textDirection: Directionality.of(context),
            onTextChanged: (final String value) {},
          ),
        ),
      ),
    );
  }
}

/// Widget that uses the custom RenderObject for markdown rendering.
class _MarkdownRenderObjectWidget extends LeafRenderObjectWidget {
  const _MarkdownRenderObjectWidget({
    required this.text,
    required this.textStyle,
    required this.onTextChanged,
    required this.textDirection,
  });

  final String text;
  final TextStyle textStyle;
  final ValueChanged<String> onTextChanged;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(final BuildContext context) =>
      MarkdownRenderObject(
        text: text,
        textStyle: textStyle,
        onTextChanged: onTextChanged,
        textDirection: textDirection,
        padding: const EdgeInsets.all(8),
      );

  @override
  void updateRenderObject(
    final BuildContext context,
    final MarkdownRenderObject renderObject,
  ) {
    renderObject
      ..text = text
      ..textStyle = textStyle
      ..textDirection = textDirection;
  }
}
