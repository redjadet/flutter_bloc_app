import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/markdown_editor/markdown_editor_widget.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

/// Page showcasing the markdown editor widget with custom RenderObject.
class MarkdownEditorPage extends StatelessWidget {
  const MarkdownEditorPage({super.key});

  @override
  Widget build(final BuildContext context) => const CommonPageLayout(
    title: 'Markdown Editor',
    body: MarkdownEditorWidget(),
  );
}
