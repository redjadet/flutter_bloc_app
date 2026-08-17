import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_delete_dialogs.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pumpDialogHost(
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
          body: TextButton(
            onPressed: () async => open(context),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('showTodoDeleteConfirmDialog', () {
    testWidgets('Cancel returns false on Material', (tester) async {
      bool? result;
      await _pumpDialogHost(
        tester,
        open: (ctx) async {
          result = await showTodoDeleteConfirmDialog(
            context: ctx,
            title: 'Buy milk',
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('Delete returns true on Cupertino', (tester) async {
      bool? result;
      await _pumpDialogHost(
        tester,
        platform: TargetPlatform.iOS,
        open: (ctx) async {
          result = await showTodoDeleteConfirmDialog(
            context: ctx,
            title: 'Buy milk',
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });
  });

  group('showTodoBatchDeleteConfirmDialog', () {
    testWidgets('confirms batch delete count', (tester) async {
      bool? result;
      await _pumpDialogHost(
        tester,
        open: (ctx) async {
          result = await showTodoBatchDeleteConfirmDialog(
            context: ctx,
            count: 3,
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.textContaining('3'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });
  });

  group('showTodoClearCompletedConfirmDialog', () {
    testWidgets('cancels clear completed flow', (tester) async {
      bool? result;
      await _pumpDialogHost(
        tester,
        open: (ctx) async {
          result = await showTodoClearCompletedConfirmDialog(
            context: ctx,
            count: 2,
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });
}
