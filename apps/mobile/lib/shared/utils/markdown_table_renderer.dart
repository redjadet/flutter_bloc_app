import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

/// Helper class for rendering markdown tables as formatted text.
///
/// Converts markdown table AST nodes into TextSpan widgets with
/// properly aligned columns using monospace font.
class MarkdownTableRenderer {
  /// Builds TextSpan list from a markdown table element.
  static List<InlineSpan> buildTableSpans(
    final md.Element tableNode,
    final TextStyle baseStyle,
  ) {
    final List<List<String>> rows = <List<String>>[];

    // Extract table structure
    for (final md.Node child in tableNode.children ?? <md.Node>[]) {
      if (child is md.Element &&
          (child.tag == 'thead' || child.tag == 'tbody')) {
        for (final md.Node rowNode in child.children ?? <md.Node>[]) {
          if (rowNode is md.Element && rowNode.tag == 'tr') {
            final List<String> row = <String>[];
            for (final md.Node cellNode in rowNode.children ?? <md.Node>[]) {
              if (cellNode is md.Element &&
                  (cellNode.tag == 'th' || cellNode.tag == 'td')) {
                final String cellText = _extractTextFromNode(cellNode);
                row.add(cellText.trim());
              }
            }
            if (row.isNotEmpty) {
              rows.add(row);
            }
          }
        }
      }
    }

    if (rows.isEmpty) {
      return const <InlineSpan>[];
    }

    // Calculate column widths
    final int columnCount = rows.isNotEmpty
        ? rows
              .map((final r) => r.length)
              .reduce((final a, final b) => a > b ? a : b)
        : 0;
    if (columnCount == 0) {
      return const <InlineSpan>[];
    }

    final List<int> columnWidths = List<int>.filled(columnCount, 0);
    for (final List<String> row in rows) {
      for (int i = 0; i < row.length && i < columnCount; i++) {
        if (row[i].length > columnWidths[i]) {
          columnWidths[i] = row[i].length;
        }
      }
    }

    // Build formatted table text
    final StringBuffer buffer = StringBuffer();
    for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final List<String> row = rows[rowIndex];

      // Build row with proper padding
      buffer.write('| ');
      for (int colIndex = 0; colIndex < columnCount; colIndex++) {
        final String cellText = colIndex < row.length ? row[colIndex] : '';
        buffer.write(cellText.padRight(columnWidths[colIndex]));
        if (colIndex < columnCount - 1) {
          buffer.write(' | ');
        }
      }
      buffer.write(' |\n');

      // Add separator after header row
      if (rowIndex == 0) {
        buffer.write('|');
        for (int colIndex = 0; colIndex < columnCount; colIndex++) {
          buffer.write('-'.padRight(columnWidths[colIndex] + 2, '-'));
          if (colIndex < columnCount - 1) {
            buffer.write('|');
          }
        }
        buffer.write('|\n');
      }
    }

    // Use monospace font for tables to maintain alignment
    final TextStyle tableStyle = baseStyle.copyWith(
      fontFamily: 'monospace',
    );

    return <InlineSpan>[
      TextSpan(text: buffer.toString(), style: tableStyle),
      const TextSpan(text: '\n'),
    ];
  }

  /// Extracts plain text content from a markdown node tree.
  static String _extractTextFromNode(final md.Node node) {
    if (node is md.Text) {
      return node.text;
    }
    if (node is md.Element) {
      final StringBuffer buffer = StringBuffer();
      for (final md.Node child in node.children ?? <md.Node>[]) {
        buffer.write(_extractTextFromNode(child));
      }
      return buffer.toString();
    }
    return '';
  }
}
