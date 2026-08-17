import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/markdown_editor/markdown_editor_widget.dart';
import 'package:material_ui/material_ui.dart';

/// Page showcasing the markdown editor widget with custom RenderObject.
class MarkdownEditorPage extends StatelessWidget {
  const MarkdownEditorPage({super.key});

  @override
  Widget build(BuildContext context) => const CommonPageLayout(
    title: 'Markdown Editor',
    body: MarkdownEditorWidget(),
  );
}
