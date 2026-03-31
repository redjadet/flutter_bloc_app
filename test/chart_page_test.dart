import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/chart/chart.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/widgets/common_empty_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChartPage shows loading then renders chart content', (
    WidgetTester tester,
  ) async {
    final Completer<List<ChartPoint>> completer = Completer<List<ChartPoint>>();
    final ChartRepository repository = _FakeChartRepository(
      () => completer.future,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChartPage(repository: repository),
      ),
    );

    expect(find.byType(ChartLoadingList), findsOneWidget);

    completer.complete(<ChartPoint>[
      ChartPoint(date: DateTime.utc(2024, 1, 1), value: 42),
      ChartPoint(date: DateTime.utc(2024, 1, 2), value: 43),
    ]);
    await tester.pump();
    await tester.pump();

    expect(find.byType(ChartContentList), findsOneWidget);
  });

  testWidgets('ChartPage shows empty state', (WidgetTester tester) async {
    final ChartRepository emptyRepo = _FakeChartRepository(
      () async => const <ChartPoint>[],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChartPage(repository: emptyRepo),
      ),
    );
    await tester.pump();
    await tester.pump();

    final CommonEmptyState emptyState = tester.widget(
      find.byType(CommonEmptyState),
    );
    expect(emptyState.message, AppLocalizationsEn().chartPageEmpty);
  });

  testWidgets('ChartPage shows error state', (WidgetTester tester) async {
    final ChartRepository errorRepo = _FakeChartRepository(
      () async => throw Exception('boom'),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChartPage(repository: errorRepo),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    final CommonEmptyState errorState = tester.widget(
      find.byType(CommonEmptyState),
    );
    expect(errorState.message, AppLocalizationsEn().chartPageError);
  });

  testWidgets(
    'ChartPage first open shows cached badge then switches to Supabase edge',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final Completer<List<ChartPoint>> refreshCompleter =
          Completer<List<ChartPoint>>();
      final ChartRepository repository = _FakeCacheThenRefreshChartRepository(
        cached: <ChartPoint>[
          ChartPoint(date: DateTime.utc(2024, 1, 1), value: 42),
        ],
        refreshResult: refreshCompleter.future,
        refreshSource: ChartDataSource.supabaseEdge,
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (final context) => buildAppMixScope(
              context,
              child: ChartPage(repository: repository),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Cache'), findsOneWidget);

      refreshCompleter.complete(<ChartPoint>[
        ChartPoint(date: DateTime.utc(2024, 1, 2), value: 43),
      ]);
      await tester.pump();
      await tester.pump();

      expect(find.text('Supabase (Edge)'), findsOneWidget);
      expect(find.text('Cache'), findsNothing);
    },
  );
}

class _FakeChartRepository extends ChartRepository {
  _FakeChartRepository(this._handler);

  final Future<List<ChartPoint>> Function() _handler;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() => _handler();
}

class _FakeCacheThenRefreshChartRepository extends ChartRepository {
  _FakeCacheThenRefreshChartRepository({
    required List<ChartPoint> cached,
    required Future<List<ChartPoint>> refreshResult,
    required ChartDataSource refreshSource,
  }) : _cached = cached,
       _refreshResult = refreshResult,
       _refreshSource = refreshSource;

  final List<ChartPoint> _cached;
  final Future<List<ChartPoint>> _refreshResult;
  final ChartDataSource _refreshSource;

  ChartDataSource _lastSource = ChartDataSource.cache;

  @override
  ChartDataSource get lastSource => _lastSource;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async => _cached;

  @override
  Future<List<ChartPoint>> loadCachedTrendingCounts() async => _cached;

  @override
  Future<List<ChartPoint>> refreshTrendingCounts() async {
    final List<ChartPoint> result = await _refreshResult;
    _lastSource = _refreshSource;
    return result;
  }
}
