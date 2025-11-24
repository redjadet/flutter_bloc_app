import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/data/profile_cache_repository.dart';
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

    setUp(() {
      repository = _MockProfileCacheRepository();
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
      when(repository.clearProfile).thenAnswer((_) async {});

      await pumpWidget(tester);

      expect(
        find.text(AppLocalizationsEn().settingsProfileCacheDescription),
        findsOneWidget,
      );

      await tester.tap(
        find.text(AppLocalizationsEn().settingsProfileCacheClearButton),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

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
    });
  });
}
