import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_history_sheet_helpers.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/utils/error_handling.dart';

void main() {
  group('Platform-Adaptive Dialog Tests', () {
    testWidgets('showClearHistoryDialog uses CupertinoAlertDialog on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await showClearHistoryDialog(context);
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Should use CupertinoAlertDialog on iOS
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      // Buttons should be tappable - use localized strings
      final l10n = AppLocalizationsEn();
      final cancelButton = find.text(l10n.cancelButtonLabel);
      expect(cancelButton, findsOneWidget);

      // Find the CupertinoDialogAction containing the Cancel text
      final cancelAction = find.ancestor(
        of: cancelButton,
        matching: find.byType(CupertinoDialogAction),
      );
      expect(cancelAction, findsOneWidget);

      // Verify the action has a non-null onPressed callback
      final cancelActionWidget = tester.widget<CupertinoDialogAction>(
        cancelAction,
      );
      expect(cancelActionWidget.onPressed, isNotNull);

      // Tap Cancel button
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.byType(CupertinoAlertDialog), findsNothing);
    });

    testWidgets('showClearHistoryDialog uses AlertDialog on Material', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await showClearHistoryDialog(context);
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Should use AlertDialog on Material
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(CupertinoAlertDialog), findsNothing);

      // Buttons should be tappable
      final cancelButton = find.text('Cancel');
      expect(cancelButton, findsOneWidget);

      // Tap Cancel button
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('showClearHistoryDialog Delete button is tappable on iOS', (
      WidgetTester tester,
    ) async {
      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    final confirmed = await showClearHistoryDialog(context);
                    if (confirmed) {
                      deleteCalled = true;
                    }
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);

      // Find and tap Delete button - use localized strings
      final l10n = AppLocalizationsEn();
      final deleteButton = find.text(l10n.deleteButtonLabel);
      expect(deleteButton, findsOneWidget);

      // Verify it's a CupertinoDialogAction
      final deleteAction = find.ancestor(
        of: deleteButton,
        matching: find.byType(CupertinoDialogAction),
      );
      expect(deleteAction, findsOneWidget);

      // Tap Delete button
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Dialog should be dismissed and delete should be called
      expect(find.byType(CupertinoAlertDialog), findsNothing);
      expect(deleteCalled, isTrue);
    });

    testWidgets(
      'showDeleteConversationDialog uses CupertinoAlertDialog on iOS',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await showDeleteConversationDialog(
                        context,
                        'Test Conversation',
                      );
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);

        // Cancel button should be tappable - use localized strings
        final l10n = AppLocalizationsEn();
        final cancelButton = find.text(l10n.cancelButtonLabel);
        expect(cancelButton, findsOneWidget);

        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoAlertDialog), findsNothing);
      },
    );

    testWidgets(
      'ErrorNotificationService.showAlertDialog uses CupertinoAlertDialog on iOS',
      (WidgetTester tester) async {
        final service = SnackbarErrorNotificationService();

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      service.showAlertDialog(context, 'Error', 'Details');
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);

        // OK button should be tappable
        final okButton = find.text('OK');
        expect(okButton, findsOneWidget);

        await tester.tap(okButton);
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoAlertDialog), findsNothing);
      },
    );

    testWidgets(
      'ErrorNotificationService.showAlertDialog uses AlertDialog on Material',
      (WidgetTester tester) async {
        final service = SnackbarErrorNotificationService();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      service.showAlertDialog(context, 'Error', 'Details');
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.byType(CupertinoAlertDialog), findsNothing);

        // OK button should be tappable
        final okButton = find.text('OK');
        expect(okButton, findsOneWidget);

        await tester.tap(okButton);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets(
      'ErrorHandling.showLoadingDialog uses CupertinoAlertDialog on iOS',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ErrorHandling.showLoadingDialog(context, 'Loading...');
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pump();

        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);

        // Should have CupertinoActivityIndicator
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        ErrorHandling.hideLoadingDialog(
          tester.element(find.text('Show Dialog')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoAlertDialog), findsNothing);
      },
    );

    testWidgets(
      'ErrorHandling.showLoadingDialog uses AlertDialog on Material',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ErrorHandling.showLoadingDialog(context, 'Loading...');
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pump();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.byType(CupertinoAlertDialog), findsNothing);

        // Should have CircularProgressIndicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(CupertinoActivityIndicator), findsNothing);

        ErrorHandling.hideLoadingDialog(
          tester.element(find.text('Show Dialog')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets('Dialog buttons are actually tappable (not just present)', (
      WidgetTester tester,
    ) async {
      bool cancelTapped = false;
      bool deleteTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    final confirmed = await showClearHistoryDialog(context);
                    if (confirmed) {
                      deleteTapped = true;
                    } else {
                      cancelTapped = true;
                    }
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);

      // Find Cancel button and verify it's interactive - use localized strings
      final l10n = AppLocalizationsEn();
      final cancelButton = find.text(l10n.cancelButtonLabel);
      expect(cancelButton, findsOneWidget);

      // Verify CupertinoDialogAction widgets exist
      final cancelActions = find.byType(CupertinoDialogAction);
      expect(cancelActions, findsNWidgets(2)); // Cancel and Delete

      // Verify Cancel button text exists and is part of a CupertinoDialogAction
      final cancelAction = find.ancestor(
        of: cancelButton,
        matching: find.byType(CupertinoDialogAction),
      );
      expect(cancelAction, findsOneWidget);

      // Verify the action has a non-null onPressed callback
      final cancelActionWidget = tester.widget<CupertinoDialogAction>(
        cancelAction,
      );
      expect(cancelActionWidget.onPressed, isNotNull);

      // Tap Cancel - this should work
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Verify dialog is dismissed and callback was called
      expect(find.byType(CupertinoAlertDialog), findsNothing);
      expect(cancelTapped, isTrue);
      expect(deleteTapped, isFalse);

      // Reset and test Delete button
      cancelTapped = false;
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      final deleteButton = find.text(l10n.deleteButtonLabel);
      expect(deleteButton, findsOneWidget);

      // Verify Delete button is part of a CupertinoDialogAction
      final deleteAction = find.ancestor(
        of: deleteButton,
        matching: find.byType(CupertinoDialogAction),
      );
      expect(deleteAction, findsOneWidget);

      // Verify the action has a non-null onPressed callback and is destructive
      final deleteActionWidget = tester.widget<CupertinoDialogAction>(
        deleteAction,
      );
      expect(deleteActionWidget.onPressed, isNotNull);
      expect(deleteActionWidget.isDestructiveAction, isTrue);

      // Tap Delete - this should work
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsNothing);
      expect(deleteTapped, isTrue);
    });
  });
}
