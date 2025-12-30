import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/markdown_editor/markdown_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarkdownParser', () {
    test('decodes HTML entities inside code blocks', () {
      final MarkdownParser parser = MarkdownParser();
      final TextSpan span = parser.buildTextSpan(
        '```dart\nprint("Hello, Flutter!");\n```',
        const TextStyle(),
      );

      expect(span.toPlainText(), contains('print("Hello, Flutter!");'));
      expect(span.toPlainText(), isNot(contains('&quot;')));
    });

    test('renders markdown tables as formatted text', () {
      final MarkdownParser parser = MarkdownParser();
      final TextSpan span = parser.buildTextSpan(
        '| Header 1 | Header 2 | Header 3 |\n'
        '|----------|----------|----------|\n'
        '| Cell 1   | Cell 2   | Cell 3   |\n'
        '| Cell 4   | Cell 5   | Cell 6   |',
        const TextStyle(),
      );

      final String plainText = span.toPlainText();
      expect(plainText, contains('Header 1'));
      expect(plainText, contains('Header 2'));
      expect(plainText, contains('Header 3'));
      expect(plainText, contains('Cell 1'));
      expect(plainText, contains('Cell 2'));
      expect(plainText, contains('|'));
    });
  });
}
