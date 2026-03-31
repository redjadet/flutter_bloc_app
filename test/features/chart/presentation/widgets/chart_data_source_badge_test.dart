import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_data_source_badge.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mix/mix.dart';

void main() {
  group('ChartDataSourceBadge', () {
    Future<void> pumpBadge(
      final WidgetTester tester, {
      required final ChartDataSource source,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (final context) => buildAppMixScope(
              context,
              child: Scaffold(body: ChartDataSourceBadge(source: source)),
            ),
          ),
        ),
      );
    }

    testWidgets('shows localized cache label', (final tester) async {
      await pumpBadge(tester, source: ChartDataSource.cache);

      expect(find.text('Cache'), findsOneWidget);
      expect(find.byType(Box), findsOneWidget);
    });

    testWidgets('shows localized remote label', (final tester) async {
      await pumpBadge(tester, source: ChartDataSource.remote);

      expect(find.text('Remote'), findsOneWidget);
      expect(find.byType(Box), findsOneWidget);
    });

    testWidgets('shows localized supabase edge label', (final tester) async {
      await pumpBadge(tester, source: ChartDataSource.supabaseEdge);

      expect(find.text('Supabase (Edge)'), findsOneWidget);
      expect(find.byType(Box), findsOneWidget);
    });

    testWidgets('shows localized supabase tables label', (final tester) async {
      await pumpBadge(tester, source: ChartDataSource.supabaseTables);

      expect(find.text('Supabase (Tables)'), findsOneWidget);
      expect(find.byType(Box), findsOneWidget);
    });

    testWidgets('renders nothing for unknown source', (final tester) async {
      await pumpBadge(tester, source: ChartDataSource.unknown);

      expect(find.text('Cache'), findsNothing);
      expect(find.text('Remote'), findsNothing);
      expect(find.byType(Box), findsNothing);
    });
  });
}
