import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/markdown_editor/markdown_editor_field.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/markdown_editor/markdown_preview.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/markdown_editor/markdown_toolbar.dart';

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
        // check-ignore: sample code block contains print() text
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

  void _togglePreview() => setState(() => _showPreview = !_showPreview);

  void _onTextChanged(final String value) => setState(() {});

  @override
  Widget build(final BuildContext context) => Column(
    children: <Widget>[
      MarkdownToolbar(
        showPreview: _showPreview,
        onTogglePreview: _togglePreview,
        controller: _controller,
      ),
      Expanded(
        child: _showPreview
            ? MarkdownPreview(text: _controller.text)
            : MarkdownEditorField(
                controller: _controller,
                scrollController: _scrollController,
                onChanged: _onTextChanged,
              ),
      ),
    ],
  );
}
