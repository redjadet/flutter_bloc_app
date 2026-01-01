import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/profile_cache_controls_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileCacheRepository extends Mock
    implements ProfileCacheRepository {}

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
  });
}
