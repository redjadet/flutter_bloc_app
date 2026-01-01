import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/graphql_cache_controls_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCacheRepository extends Mock implements GraphqlCacheRepository {}

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
  });
}
