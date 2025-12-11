import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/markdown_editor/markdown_editor_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarkdownEditorWidget', () {
    testWidgets('renders editor with toolbar', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MarkdownEditorWidget())),
      );

      expect(find.text('Markdown Editor'), findsOneWidget);
      expect(find.byIcon(Icons.preview), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('toggles between edit and preview modes', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MarkdownEditorWidget())),
      );

      // Initially in edit mode
      expect(find.byType(TextField), findsOneWidget);

      // Switch to preview
      await tester.tap(find.byIcon(Icons.preview));
      await tester.pump();

      // Should show preview (no TextField)
      expect(find.byType(TextField), findsNothing);

      // Switch back to edit
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('allows text input', (final WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MarkdownEditorWidget())),
      );

      final Finder textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, '# Test Header\n\n**Bold text**');
      await tester.pump();

      expect(find.textContaining('Test Header'), findsOneWidget);
    });

    testWidgets('shows markdown shortcuts menu', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MarkdownEditorWidget())),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump();

      expect(find.text('Header (#)'), findsOneWidget);
      expect(find.text('Bold (**)'), findsOneWidget);
      expect(find.text('Italic (*)'), findsOneWidget);
      expect(find.text('Inline Code (`)'), findsOneWidget);
      expect(find.text('Code Block (```)'), findsOneWidget);
    });

    testWidgets('applies formatting even without an active selection', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MarkdownEditorWidget())),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bold (**)'));
      await tester.pump();

      final TextField textField = tester.widget<TextField>(
        find.byType(TextField),
      );
      expect(textField.controller?.text.endsWith('****'), isTrue);
    });
  });
}
