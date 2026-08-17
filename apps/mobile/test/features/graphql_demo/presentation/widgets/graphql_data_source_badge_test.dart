import 'package:flutter_bloc_app/app/theme/theme.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/widgets/graphql_data_source_badge.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mix/mix.dart';

void main() {
  group('GraphqlDataSourceBadge', () {
    Future<void> pumpBadge(
      WidgetTester tester, {
      required GraphqlDataSource source,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => buildAppMixScope(
              context,
              child: Scaffold(body: GraphqlDataSourceBadge(source: source)),
            ),
          ),
        ),
      );
    }

    testWidgets('shows localized cache label', (tester) async {
      await pumpBadge(tester, source: GraphqlDataSource.cache);

      expect(find.text('Cache'), findsOneWidget);
      expect(find.byType(Box), findsOneWidget);
    });

    testWidgets('shows localized remote label', (tester) async {
      await pumpBadge(tester, source: GraphqlDataSource.remote);

      expect(find.text('Remote'), findsOneWidget);
      expect(find.byType(Box), findsOneWidget);
    });

    testWidgets('shows localized supabase edge label', (tester) async {
      await pumpBadge(tester, source: GraphqlDataSource.supabaseEdge);

      expect(find.text('Supabase (Edge)'), findsOneWidget);
      expect(find.byType(Box), findsOneWidget);
    });

    testWidgets('shows localized supabase tables label', (tester) async {
      await pumpBadge(tester, source: GraphqlDataSource.supabaseTables);

      expect(find.text('Supabase (Tables)'), findsOneWidget);
      expect(find.byType(Box), findsOneWidget);
    });

    testWidgets('renders nothing for unknown source', (tester) async {
      await pumpBadge(tester, source: GraphqlDataSource.unknown);

      expect(find.text('Cache'), findsNothing);
      expect(find.text('Remote'), findsNothing);
      expect(find.byType(Box), findsNothing);
    });
  });
}
