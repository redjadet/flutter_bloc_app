import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/diagnostics/graphql_cache_clear_port.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/widgets/diagnostics/graphql_cache_controls_section.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCacheRepository extends Mock implements GraphqlCacheClearPort {}

void main() {
  group('GraphqlCacheControlsSection', () {
    late _MockCacheRepository repository;

    setUp(() {
      repository = _MockCacheRepository();
    });

    Future<void> pump(final WidgetTester tester) {
      return tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: GraphqlCacheControlsSection(cacheRepository: repository),
          ),
        ),
      );
    }

    testWidgets('clears cache when button tapped', (tester) async {
      when(() => repository.clear()).thenAnswer((_) async {});

      await pump(tester);
      await tester.tap(find.text('Clear GraphQL cache'));
      await tester.pump();

      verify(() => repository.clear()).called(1);
    });

    testWidgets('does not throw after dispose while clear is in flight', (
      final WidgetTester tester,
    ) async {
      final Completer<void> clearCompleter = Completer<void>();
      when(() => repository.clear()).thenAnswer((_) => clearCompleter.future);

      await pump(tester);
      await tester.tap(find.text('Clear GraphQL cache'));
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(
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
  });
}
