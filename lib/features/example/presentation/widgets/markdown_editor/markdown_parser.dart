import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

/// Markdown parser that leverages the `markdown` package for accurate AST parsing
/// and builds a styled [TextSpan] tree for our render object.
class MarkdownParser {
  MarkdownParser()
    : _document = md.Document(extensionSet: md.ExtensionSet.gitHubFlavored);

  final md.Document _document;

  TextSpan buildTextSpan(
    final String text,
    final TextStyle baseStyle,
  ) {
    if (text.isEmpty) {
      return TextSpan(text: '', style: baseStyle);
    }

    final List<md.Node> nodes = _document.parseLines(text.split('\n'));
    final List<InlineSpan> spans = <InlineSpan>[];

    for (final md.Node node in nodes) {
      spans.addAll(_buildNodeSpans(node, baseStyle));
    }

    return TextSpan(
      style: baseStyle,
      children: _trimTrailingBreaks(spans),
    );
  }

  List<InlineSpan> _buildNodeSpans(
    final md.Node node,
    final TextStyle currentStyle,
  ) {
    if (node is md.Text) {
      return <InlineSpan>[
        TextSpan(text: _decodeHtmlEntities(node.text), style: currentStyle),
      ];
    }

    if (node is! md.Element) return const <InlineSpan>[];

    final TextStyle resolvedStyle =
        _styleForTag(node.tag, currentStyle) ?? currentStyle;
    final List<InlineSpan> children = <InlineSpan>[];

    for (final md.Node child in node.children ?? <md.Node>[]) {
      children.addAll(_buildNodeSpans(child, resolvedStyle));
    }

    switch (node.tag) {
      case 'p':
        return <InlineSpan>[
          TextSpan(children: children, style: resolvedStyle),
          const TextSpan(text: '\n\n'),
        ];
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        return <InlineSpan>[
          TextSpan(children: children, style: resolvedStyle),
          const TextSpan(text: '\n'),
        ];
      case 'li':
        return <InlineSpan>[
          const TextSpan(text: '• '),
          ...children,
          const TextSpan(text: '\n'),
        ];
      case 'blockquote':
        return <InlineSpan>[
          TextSpan(
            text: '│ ',
            style: resolvedStyle.copyWith(
              color: resolvedStyle.color?.withValues(alpha: 0.7),
            ),
          ),
          ...children,
          const TextSpan(text: '\n'),
        ];
      case 'ul':
      case 'ol':
        return <InlineSpan>[TextSpan(children: children, style: resolvedStyle)];
      case 'pre':
        return <InlineSpan>[
          TextSpan(children: children, style: resolvedStyle),
          const TextSpan(text: '\n\n'),
        ];
      case 'code':
        return <InlineSpan>[TextSpan(children: children, style: resolvedStyle)];
      default:
        return <InlineSpan>[TextSpan(children: children, style: resolvedStyle)];
    }
  }

  TextStyle? _styleForTag(final String? tag, final TextStyle baseStyle) {
    switch (tag) {
      case 'h1':
        return baseStyle.copyWith(
          fontSize: (baseStyle.fontSize ?? 16) * 1.8,
          fontWeight: FontWeight.bold,
        );
      case 'h2':
        return baseStyle.copyWith(
          fontSize: (baseStyle.fontSize ?? 16) * 1.6,
          fontWeight: FontWeight.bold,
        );
      case 'h3':
        return baseStyle.copyWith(
          fontSize: (baseStyle.fontSize ?? 16) * 1.4,
          fontWeight: FontWeight.w600,
        );
      case 'h4':
        return baseStyle.copyWith(
          fontSize: (baseStyle.fontSize ?? 16) * 1.25,
          fontWeight: FontWeight.w600,
        );
      case 'h5':
      case 'h6':
        return baseStyle.copyWith(
          fontSize: (baseStyle.fontSize ?? 16) * 1.1,
          fontWeight: FontWeight.w600,
        );
      case 'strong':
        return baseStyle.copyWith(fontWeight: FontWeight.bold);
      case 'em':
        return baseStyle.copyWith(fontStyle: FontStyle.italic);
      case 'code':
      case 'pre':
        return baseStyle.copyWith(
          fontFamily: 'monospace',
          backgroundColor: baseStyle.color?.withValues(alpha: 0.08),
        );
      case 'blockquote':
        return baseStyle.copyWith(
          fontStyle: FontStyle.italic,
          color: baseStyle.color?.withValues(alpha: 0.8),
        );
      default:
        return null;
    }
  }

  List<InlineSpan> _trimTrailingBreaks(final List<InlineSpan> spans) {
    final List<InlineSpan> result = List<InlineSpan>.from(spans);
    while (result.isNotEmpty) {
      final InlineSpan last = result.last;
      if (last is TextSpan &&
          last.text != null &&
          last.text!.trim().isEmpty &&
          (last.text!.contains('\n') || last.text!.contains(' ')) &&
          (last.children == null || last.children!.isEmpty)) {
        result.removeLast();
      } else {
        break;
      }
    }
    return result;
  }

  String _decodeHtmlEntities(final String input) => input
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');
}
