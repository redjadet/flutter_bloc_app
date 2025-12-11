import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/markdown_editor/markdown_render_object.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

/// A markdown editor widget using a custom RenderObject for low-level text rendering.
///
/// Features:
/// - Real-time markdown syntax highlighting
/// - Custom RenderObject for efficient text layout
/// - Scrollable editor with preview
/// - Responsive design
class MarkdownEditorWidget extends StatefulWidget {
  const MarkdownEditorWidget({super.key});

  @override
  State<MarkdownEditorWidget> createState() => _MarkdownEditorWidgetState();
}

class _MarkdownEditorWidgetState extends State<MarkdownEditorWidget> {
  final TextEditingController _controller = TextEditingController(
    text:
        '# Markdown Editor\n\nThis editor uses a **custom RenderObject** for rendering.\n\n- Supports *italic* and **bold** text\n- `Inline code` and code blocks\n- Headers with # symbols\n\n```dart\nvoid main() {\n  print("Hello, Flutter!");\n}\n```',
  );
  final ScrollController _scrollController = ScrollController();
  bool _showPreview = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Column(
      children: <Widget>[
        // Toolbar
        Container(
          padding: EdgeInsets.all(context.responsiveGapS),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(
                color: colors.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              Text(
                'Markdown Editor',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              // Toggle preview
              IconButton(
                onPressed: () {
                  setState(() {
                    _showPreview = !_showPreview;
                  });
                },
                icon: Icon(_showPreview ? Icons.edit : Icons.preview),
                tooltip: _showPreview ? 'Edit' : 'Preview',
              ),
              // Insert markdown shortcuts
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (final String value) {
                  final String text = _controller.text;
                  final int selectionStart = _normalizeSelectionIndex(
                    _controller.selection.start,
                    text.length,
                  );
                  final int selectionEnd = _normalizeSelectionIndex(
                    _controller.selection.end,
                    text.length,
                  );
                  final int start = math.min(selectionStart, selectionEnd);
                  final int end = math.max(selectionStart, selectionEnd);

                  final String before = text.substring(0, start);
                  final String selected = text.substring(
                    start,
                    end,
                  );
                  final String after = text.substring(end);

                  String newText;
                  int newCursorPosition;

                  switch (value) {
                    case 'header':
                      newText = '$before# $selected$after';
                      newCursorPosition = start + 2;
                      break;
                    case 'bold':
                      newText = '$before**$selected**$after';
                      newCursorPosition = end + 2;
                      break;
                    case 'italic':
                      newText = '$before*$selected*$after';
                      newCursorPosition = end + 1;
                      break;
                    case 'code':
                      newText = '$before`$selected`$after';
                      newCursorPosition = end + 1;
                      break;
                    case 'codeblock':
                      newText = '$before```\n$selected\n```$after';
                      newCursorPosition = end + 5;
                      break;
                    default:
                      return;
                  }

                  _controller.value = TextEditingValue(
                    text: newText,
                    selection: TextSelection.collapsed(
                      offset: newCursorPosition,
                    ),
                  );
                },
                itemBuilder: (final BuildContext context) =>
                    <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'header',
                        child: Text('Header (#)'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'bold',
                        child: Text('Bold (**)'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'italic',
                        child: Text('Italic (*)'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'code',
                        child: Text('Inline Code (`)'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'codeblock',
                        child: Text('Code Block (```)'),
                      ),
                    ],
              ),
            ],
          ),
        ),
        // Editor/Preview
        Expanded(
          child: _showPreview
              ? _buildPreview(context, theme, colors)
              : _buildEditor(context, theme, colors),
        ),
      ],
    );
  }

  Widget _buildEditor(
    final BuildContext context,
    final ThemeData theme,
    final ColorScheme colors,
  ) => Container(
    padding: EdgeInsets.all(context.responsiveGapM),
    color: colors.surface,
    child: TextField(
      controller: _controller,
      scrollController: _scrollController,
      maxLines: null,
      expands: true,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText:
            'Start typing markdown...\n\n# Header\n**Bold**\n*Italic*\n`Code`',
        border: InputBorder.none,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.5),
        ),
      ),
      onChanged: (final String value) => setState(() {
        // Trigger rebuild to update preview if visible
        // The preview will automatically update via the widget's text property
      }),
    ),
  );

  Widget _buildPreview(
    final BuildContext context,
    final ThemeData theme,
    final ColorScheme colors,
  ) => Container(
    padding: EdgeInsets.all(context.responsiveGapM),
    color: colors.surface,
    child: SingleChildScrollView(
      child: IntrinsicWidth(
        child: _MarkdownRenderObjectWidget(
          text: _controller.text,
          textStyle: theme.textTheme.bodyLarge!,
          textDirection: Directionality.of(context),
          onTextChanged: (final String value) {},
        ),
      ),
    ),
  );

  int _normalizeSelectionIndex(final int index, final int maxLength) {
    if (index.isNegative) {
      return maxLength;
    }
    if (index > maxLength) {
      return maxLength;
    }
    return index;
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
