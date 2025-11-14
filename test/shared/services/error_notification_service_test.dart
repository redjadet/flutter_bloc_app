import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SnackbarErrorNotificationService', () {
    final service = SnackbarErrorNotificationService();

    testWidgets('shows floating snackbar when messenger available', (
      WidgetTester tester,
    ) async {
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (builderContext) {
                context = builderContext;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      unawaited(service.showSnackBar(context, 'Something went wrong'));
      await tester.pump();

      final SnackBar snackBar = tester.widget(find.byType(SnackBar));
      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('skips snackbar when no messenger exists', (
      WidgetTester tester,
    ) async {
      late BuildContext context;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (builderContext) {
              context = builderContext;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      unawaited(service.showSnackBar(context, 'Ignored'));
      await tester.pump();

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('showAlertDialog displays dismissible dialog', (
      WidgetTester tester,
    ) async {
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (builderContext) {
                context = builderContext;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final Future<void> dialogFuture = service.showAlertDialog(
        context,
        'Error',
        'Details',
      );
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await dialogFuture;

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('showAlertDialog uses CupertinoAlertDialog on iOS', (
      WidgetTester tester,
    ) async {
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Builder(
              builder: (builderContext) {
                context = builderContext;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final Future<void> dialogFuture = service.showAlertDialog(
        context,
        'Error',
        'Details',
      );
      await tester.pumpAndSettle();

      // Should use CupertinoAlertDialog on iOS
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);

      // OK button should be tappable
      final okButton = find.text('OK');
      expect(okButton, findsOneWidget);

      // Verify it's a CupertinoDialogAction
      final okAction = find.ancestor(
        of: okButton,
        matching: find.byType(CupertinoDialogAction),
      );
      expect(okAction, findsOneWidget);

      final okActionWidget = tester.widget<CupertinoDialogAction>(okAction);
      expect(okActionWidget.onPressed, isNotNull);

      await tester.tap(okButton);
      await tester.pumpAndSettle();
      await dialogFuture;

      expect(find.byType(CupertinoAlertDialog), findsNothing);
    });

    testWidgets('showAlertDialog is skipped for unmounted context', (
      WidgetTester tester,
    ) async {
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (builderContext, setState) {
              context = builderContext;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      await service.showAlertDialog(context, 'Title', 'Message');
      await tester.pump();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
