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
  });
}
