import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/widgets/listen_button.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpButton(
    WidgetTester tester, {
    VoidCallback? onPressed,
    bool compact = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListenButton(onPressed: onPressed ?? () {}, compact: compact),
        ),
      ),
    );
  }

  group('ListenButton', () {
    testWidgets('renders and is tappable', (WidgetTester tester) async {
      await pumpButton(tester);

      expect(find.byType(ListenButton), findsOneWidget);
      await tester.tap(find.byType(ListenButton));
    });

    testWidgets('compact mode shows icon only', (WidgetTester tester) async {
      await pumpButton(tester, compact: true);

      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });

    testWidgets('non-compact shows listen label', (WidgetTester tester) async {
      await pumpButton(tester, compact: false);

      expect(find.text(AppLocalizationsEn().playlearnListen), findsOneWidget);
    });
  });
}
