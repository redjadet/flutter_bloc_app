import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

/// Toolbar for the markdown editor with preview toggle and markdown shortcuts.
class MarkdownToolbar extends StatelessWidget {
  const MarkdownToolbar({
    required this.showPreview,
    required this.onTogglePreview,
    required this.controller,
    super.key,
  });

  final bool showPreview;
  final VoidCallback onTogglePreview;
  final TextEditingController controller;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: context.allGapS,
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
            onPressed: onTogglePreview,
            icon: Icon(showPreview ? Icons.edit : Icons.preview),
            tooltip: showPreview ? 'Edit' : 'Preview',
          ),
          // Insert markdown shortcuts
          MarkdownShortcutsMenu(controller: controller),
        ],
      ),
    );
  }
}

/// Popup menu for inserting markdown shortcuts.
class MarkdownShortcutsMenu extends StatelessWidget {
  const MarkdownShortcutsMenu({required this.controller, super.key});

  final TextEditingController controller;

  void _insertMarkdown(final String type) {
    final String text = controller.text;
    final int selectionStart = _normalizeSelectionIndex(
      controller.selection.start,
      text.length,
    );
    final int selectionEnd = _normalizeSelectionIndex(
      controller.selection.end,
      text.length,
    );
    final int start = math.min(selectionStart, selectionEnd);
    final int end = math.max(selectionStart, selectionEnd);

    final String before = text.substring(0, start);
    final String selected = text.substring(start, end);
    final String after = text.substring(end);

    late final String newText;
    late final int newCursorPosition;

    switch (type) {
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

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  int _normalizeSelectionIndex(final int index, final int maxLength) {
    if (index.isNegative) {
      return maxLength;
    }
    if (index > maxLength) {
      return maxLength;
    }
    return index;
  }

  @override
  Widget build(final BuildContext context) => PopupMenuButton<String>(
    icon: const Icon(Icons.more_vert),
    onSelected: _insertMarkdown,
    itemBuilder: (final context) => <PopupMenuEntry<String>>[
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
  );
}
