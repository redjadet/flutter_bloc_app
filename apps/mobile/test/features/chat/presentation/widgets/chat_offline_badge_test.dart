import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_offline_badge.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('offline badge exposes semantics label from l10n', (
    final WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (final BuildContext context) => Scaffold(
            body: buildAppMixScope(context, child: const ChatOfflineBadge()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext badgeContext = tester.element(
      find.byType(ChatOfflineBadge),
    );
    final String expectedSemantics = AppLocalizations.of(
      badgeContext,
    ).chatOfflineBadgeSemanticsLabel;

    expect(find.bySemanticsLabel(expectedSemantics), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);

    handle.dispose();
  });
}
