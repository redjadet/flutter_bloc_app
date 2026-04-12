import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_transport_badge.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows Supabase label for ChatInferenceTransport.supabase', (
    final WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (final BuildContext context, final Widget? child) =>
            buildAppMixScope(context, child: child ?? const SizedBox.shrink()),
        home: const Scaffold(
          body: ChatTransportBadge(transport: ChatInferenceTransport.supabase),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext badgeContext = tester.element(
      find.byType(ChatTransportBadge),
    );
    final String expectedSemantics = AppLocalizations.of(
      badgeContext,
    ).chatTransportSupabaseSemanticsLabel;

    expect(find.text('Supabase'), findsOneWidget);
    expect(find.bySemanticsLabel(expectedSemantics), findsOneWidget);

    handle.dispose();
  });

  testWidgets('shows Direct label for ChatInferenceTransport.direct', (
    final WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (final BuildContext context, final Widget? child) =>
            buildAppMixScope(context, child: child ?? const SizedBox.shrink()),
        home: const Scaffold(
          body: ChatTransportBadge(transport: ChatInferenceTransport.direct),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext badgeContext = tester.element(
      find.byType(ChatTransportBadge),
    );
    final String expectedSemantics = AppLocalizations.of(
      badgeContext,
    ).chatTransportDirectSemanticsLabel;

    expect(find.text('Direct'), findsOneWidget);
    expect(find.bySemanticsLabel(expectedSemantics), findsOneWidget);

    handle.dispose();
  });

  testWidgets('shows Orchestration label for ChatInferenceTransport.renderOrchestration', (
    final WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (final BuildContext context, final Widget? child) =>
            buildAppMixScope(context, child: child ?? const SizedBox.shrink()),
        home: const Scaffold(
          body: ChatTransportBadge(transport: ChatInferenceTransport.renderOrchestration),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext badgeContext = tester.element(find.byType(ChatTransportBadge));
    final String expectedSemantics = AppLocalizations.of(
      badgeContext,
    ).chatTransportRenderOrchestrationSemanticsLabel;

    expect(find.text('Orchestration'), findsOneWidget);
    expect(find.bySemanticsLabel(expectedSemantics), findsOneWidget);

    handle.dispose();
  });

  testWidgets('shows strict mode copy under orchestration when renderDemoStrict', (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (final BuildContext context, final Widget? child) =>
            buildAppMixScope(context, child: child ?? const SizedBox.shrink()),
        home: const Scaffold(
          body: ChatTransportBadge(
            transport: ChatInferenceTransport.renderOrchestration,
            renderDemoStrict: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppLocalizationsEn().chatRenderStrictMode), findsOneWidget);
    expect(find.text('Orchestration'), findsOneWidget);
  });

  testWidgets('does not show strict copy for non-orchestration even when renderDemoStrict', (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (final BuildContext context, final Widget? child) =>
            buildAppMixScope(context, child: child ?? const SizedBox.shrink()),
        home: const Scaffold(
          body: ChatTransportBadge(
            transport: ChatInferenceTransport.supabase,
            renderDemoStrict: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppLocalizationsEn().chatRenderStrictMode), findsNothing);
  });
}
