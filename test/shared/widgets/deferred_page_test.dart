import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:flutter_bloc_app/shared/widgets/deferred_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeferredPage', () {
    testWidgets('shows loading while loadLibrary is in progress', (
      WidgetTester tester,
    ) async {
      final Completer<void> completer = Completer<void>();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DeferredPage(
            loadLibrary: () => completer.future,
            builder: (final context) => const Text('Loaded'),
          ),
        ),
      );

      expect(find.byType(CommonLoadingWidget), findsOneWidget);
      expect(find.text('Loaded'), findsNothing);
    });

    testWidgets('shows builder content when loadLibrary completes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DeferredPage(
            loadLibrary: () async {},
            builder: (final context) => const Text('Loaded'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Loaded'), findsOneWidget);
    });

    testWidgets('shows error view when loadLibrary throws', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DeferredPage(
            loadLibrary: () => Future<void>.error(Exception('load failed')),
            builder: (final context) => const Text('Loaded'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CommonErrorView), findsOneWidget);
      expect(find.text('Loaded'), findsNothing);
    });
  });
}
