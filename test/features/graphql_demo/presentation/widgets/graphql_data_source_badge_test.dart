import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/widgets/graphql_data_source_badge.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mix/mix.dart';

void main() {
  group('GraphqlDataSourceBadge', () {
    Future<void> pumpBadge(
      final WidgetTester tester, {
      required final GraphqlDataSource source,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (final context) => MixTheme(
              data: buildAppMixThemeData(context),
              child: Scaffold(body: GraphqlDataSourceBadge(source: source)),
            ),
          ),
        ),
      );
    }

    testWidgets('shows localized cache label', (final tester) async {
      await pumpBadge(tester, source: GraphqlDataSource.cache);

      expect(find.text('Cache'), findsOneWidget);
      expect(find.byType(Box), findsOneWidget);
    });

    testWidgets('shows localized remote label', (final tester) async {
      await pumpBadge(tester, source: GraphqlDataSource.remote);

      expect(find.text('Remote'), findsOneWidget);
      expect(find.byType(Box), findsOneWidget);
    });

    testWidgets('renders nothing for unknown source', (final tester) async {
      await pumpBadge(tester, source: GraphqlDataSource.unknown);

      expect(find.text('Cache'), findsNothing);
      expect(find.text('Remote'), findsNothing);
      expect(find.byType(Box), findsNothing);
    });
  });
}
