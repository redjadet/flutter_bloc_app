import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/app/widgets/deferred_page.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('DeferredPage', () {
    testWidgets('shows loading while loadLibrary is in progress', (
      WidgetTester tester,
    ) async {
      final Completer<void> completer = Completer<void>();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DeferredPage(
            loadLibrary: () => completer.future,
            builder: (context) => const Text('Loaded'),
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
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DeferredPage(
            loadLibrary: () async {},
            builder: (context) => const Text('Loaded'),
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
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DeferredPage(
            loadLibrary: () => Future<void>.error(Exception('load failed')),
            builder: (context) => const Text('Loaded'),
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
