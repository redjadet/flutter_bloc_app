import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/chart.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
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

  testWidgets('ChartPage shows empty and error states', (
    WidgetTester tester,
  ) async {
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
    ChartMessageList messageList = tester.widget(find.byType(ChartMessageList));
    expect(messageList.message, AppLocalizationsEn().chartPageEmpty);

    final ChartRepository errorRepo = _FakeChartRepository(
      () async => throw Exception('boom'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

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
    messageList = tester.widget(find.byType(ChartMessageList));
    expect(messageList.message, AppLocalizationsEn().chartPageError);
  });
}

class _FakeChartRepository extends ChartRepository {
  _FakeChartRepository(this._handler);

  final Future<List<ChartPoint>> Function() _handler;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() => _handler();
}
