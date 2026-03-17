import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/helpers/todo_list_dialogs.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpDialog(
  final WidgetTester tester, {
  required final Future<void> Function(BuildContext) open,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (final context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async => open(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('showTodoEditorDialog', () {
    testWidgets('Cancel returns null', (final tester) async {
      TodoEditorResult? result;
      await _pumpDialog(
        tester,
        open: (final ctx) async {
          result = await showTodoEditorDialog(context: ctx);
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('New todo'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('valid title and Save returns TodoEditorResult', (
      final tester,
    ) async {
      TodoEditorResult? result;
      await _pumpDialog(
        tester,
        open: (final ctx) async {
          result = await showTodoEditorDialog(context: ctx);
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Buy milk');
      await tester.pumpAndSettle();
      // Trigger rebuild so Save becomes enabled (dialog does not listen to title controller).
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.title, 'Buy milk');
      expect(result!.description, '');
      expect(result!.isCompleted, isFalse);
    });

    testWidgets('empty title keeps Save disabled and dialog open', (
      final tester,
    ) async {
      TodoEditorResult? result;
      await _pumpDialog(
        tester,
        open: (final ctx) async {
          result = await showTodoEditorDialog(context: ctx);
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('New todo'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(find.text('New todo'), findsOneWidget);
    });
  });
}
