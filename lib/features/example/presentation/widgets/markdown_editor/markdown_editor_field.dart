import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

/// Text field component for editing markdown content.
class MarkdownEditorField extends StatelessWidget {
  const MarkdownEditorField({
    required this.controller,
    required this.scrollController,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ScrollController scrollController;
  final ValueChanged<String> onChanged;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: context.allGapM,
      color: colors.surface,
      child: TextField(
        controller: controller,
        scrollController: scrollController,
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
        onChanged: onChanged,
      ),
    );
  }
}
