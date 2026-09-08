import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_dialogs.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pumpDialog(
  WidgetTester tester, {
  required Future<void> Function(BuildContext) open,
  TargetPlatform platform = TargetPlatform.android,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      locale: const Locale('en'),
      localizationsDelegates: appLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
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
    testWidgets('Cancel returns null', (tester) async {
      TodoEditorResult? result;
      await _pumpDialog(
        tester,
        open: (ctx) async {
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
      tester,
    ) async {
      TodoEditorResult? result;
      await _pumpDialog(
        tester,
        open: (ctx) async {
          result = await showTodoEditorDialog(context: ctx);
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Buy milk');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.title, 'Buy milk');
      expect(result!.description, '');
      expect(result!.isCompleted, isFalse);
    });

    testWidgets('empty title keeps Save disabled and dialog open', (
      tester,
    ) async {
      TodoEditorResult? result;
      await _pumpDialog(
        tester,
        open: (ctx) async {
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

    testWidgets('title Next action moves focus to description', (tester) async {
      await _pumpDialog(
        tester,
        open: (ctx) async {
          await showTodoEditorDialog(context: ctx);
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final Finder titleField = find.byType(TextField).first;
      final Finder descriptionField = find.byType(TextField).at(1);

      expect(
        tester.widget<TextField>(titleField).textInputAction,
        TextInputAction.next,
      );

      await tester.enterText(titleField, 'Buy milk');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();

      final FocusNode? descriptionFocus = tester
          .widget<TextField>(descriptionField)
          .focusNode;
      expect(descriptionFocus?.hasFocus, isTrue);
    });

    testWidgets('iOS dialog requests keyboard focus for the title field', (
      tester,
    ) async {
      await _pumpDialog(
        tester,
        platform: TargetPlatform.iOS,
        open: (ctx) async {
          await showTodoEditorDialog(context: ctx);
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoTextField), findsWidgets);
      expect(tester.testTextInput.hasAnyClients, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.enterText(find.byType(CupertinoTextField).first, 'Buy milk');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('New todo'), findsNothing);
    });

    testWidgets('iOS title Next action moves focus to description', (
      tester,
    ) async {
      await _pumpDialog(
        tester,
        platform: TargetPlatform.iOS,
        open: (ctx) async {
          await showTodoEditorDialog(context: ctx);
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final Finder titleField = find.byType(CupertinoTextField).first;
      final Finder descriptionField = find.byType(CupertinoTextField).at(1);

      expect(
        tester.widget<CupertinoTextField>(titleField).textInputAction,
        TextInputAction.next,
      );

      await tester.enterText(titleField, 'Buy milk');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();

      final FocusNode? descriptionFocus = tester
          .widget<CupertinoTextField>(descriptionField)
          .focusNode;
      expect(descriptionFocus?.hasFocus, isTrue);
    });
  });
}
