import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/diagnostics/profile_cache_controls_port.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/widgets/diagnostics/profile_cache_controls_section.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileCacheRepository extends Mock
    implements ProfileCacheControlsPort {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileCacheControlsSection', () {
    late _MockProfileCacheRepository repository;
    const ProfileCacheMetadata metadata = ProfileCacheMetadata(
      hasProfile: true,
      lastSyncedAt: null,
      sizeBytes: 1024,
    );

    setUp(() {
      repository = _MockProfileCacheRepository();
      when(repository.loadMetadata).thenAnswer((_) async => metadata);
      when(repository.clearProfile).thenAnswer((_) async {});
    });

    Future<void> pumpWidget(final WidgetTester tester) {
      return tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ProfileCacheControlsSection(
              profileCacheRepository: repository,
            ),
          ),
        ),
      );
    }

    testWidgets('clears cache when button tapped', (
      final WidgetTester tester,
    ) async {
      await pumpWidget(tester);
      await tester.pumpAndSettle();

      expect(
        find.text(AppLocalizationsEn().settingsProfileCacheDescription),
        findsOneWidget,
      );
      expect(find.textContaining('Cache size'), findsOneWidget);

      await tester.tap(
        find.text(AppLocalizationsEn().settingsProfileCacheClearButton),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      verify(repository.clearProfile).called(1);
      expect(
        find.text(AppLocalizationsEn().settingsProfileCacheClearedMessage),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator while clearing cache', (
      final WidgetTester tester,
    ) async {
      final Completer<void> completer = Completer<void>();
      when(repository.clearProfile).thenAnswer((_) => completer.future);

      await pumpWidget(tester);
      await tester.pump();

      await tester.tap(
        find.text(AppLocalizationsEn().settingsProfileCacheClearButton),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();

      expect(
        find.text(AppLocalizationsEn().settingsProfileCacheClearedMessage),
        findsOneWidget,
      );
      verify(repository.loadMetadata).called(greaterThanOrEqualTo(1));
    });

    testWidgets('shows metadata after load', (tester) async {
      when(repository.loadMetadata).thenAnswer(
        (_) async => const ProfileCacheMetadata(
          hasProfile: true,
          lastSyncedAt: null,
          sizeBytes: 2048,
        ),
      );

      await pumpWidget(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining('Cache size'), findsOneWidget);
    });

    testWidgets('omits negative sizeBytes and still shows last synced', (
      final WidgetTester tester,
    ) async {
      when(repository.loadMetadata).thenAnswer(
        (_) async => ProfileCacheMetadata(
          hasProfile: true,
          lastSyncedAt: DateTime.utc(2020, 6, 15),
          sizeBytes: -1,
        ),
      );

      await pumpWidget(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining('Last synced'), findsOneWidget);
      expect(find.textContaining('Cache size'), findsNothing);
    });

    testWidgets('uses fallback when hasProfile but no displayable fields', (
      final WidgetTester tester,
    ) async {
      when(repository.loadMetadata).thenAnswer(
        (_) async => const ProfileCacheMetadata(
          hasProfile: true,
          lastSyncedAt: null,
          sizeBytes: -1,
        ),
      );

      await pumpWidget(tester);
      await tester.pumpAndSettle();

      expect(
        find.text(AppLocalizationsEn().profileCachedProfileDetailsUnavailable),
        findsOneWidget,
      );
    });

    testWidgets(
      'uses no-cache string when nothing displayable and no profile',
      (final WidgetTester tester) async {
        when(repository.loadMetadata).thenAnswer(
          (_) async => const ProfileCacheMetadata(
            hasProfile: false,
            lastSyncedAt: null,
            sizeBytes: -1,
          ),
        );

        await pumpWidget(tester);
        await tester.pumpAndSettle();

        expect(
          find.text(AppLocalizationsEn().profileNoCachedProfile),
          findsOneWidget,
        );
      },
    );

    testWidgets('hides implausible lastSynced but keeps valid cache size', (
      final WidgetTester tester,
    ) async {
      when(repository.loadMetadata).thenAnswer(
        (_) async => ProfileCacheMetadata(
          hasProfile: true,
          lastSyncedAt: DateTime.utc(3000, 1, 1),
          sizeBytes: 512,
        ),
      );

      await pumpWidget(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining('Last synced'), findsNothing);
      expect(find.textContaining('Cache size'), findsOneWidget);
    });

    testWidgets('does not setState after dispose while clear is in flight', (
      final WidgetTester tester,
    ) async {
      final Completer<void> clearCompleter = Completer<void>();
      when(repository.clearProfile).thenAnswer((_) => clearCompleter.future);

      await pumpWidget(tester);
      await tester.pump();

      await tester.tap(
        find.text(AppLocalizationsEn().settingsProfileCacheClearButton),
      );
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      );
      await tester.pump();

      clearCompleter.complete();
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('stops metadata loading spinner when loadMetadata fails', (
      final WidgetTester tester,
    ) async {
      when(
        repository.loadMetadata,
      ).thenAnswer((_) async => throw Exception('metadata fail'));

      await pumpWidget(tester);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
