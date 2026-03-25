import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/presentation/cubit/chart_cubit.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_content_list.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_line_graph.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_loading_list.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  final List<ChartPoint> samplePoints = <ChartPoint>[
    ChartPoint(date: DateTime.utc(2024, 1, 1), value: 42.0),
    ChartPoint(date: DateTime.utc(2024, 1, 2), value: 43.5),
  ];
  final DateFormat format = DateFormat('MMM d');

  testWidgets('ChartContentList renders chart and toggles zoom', (
    WidgetTester tester,
  ) async {
    final cubit = ChartCubit(repository: _FakeChartRepository());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: ChartContentList(
              l10n: AppLocalizationsEn(),
              points: samplePoints,
              dateFormat: format,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ChartLineGraph), findsOneWidget);
    final interactiveViewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(interactiveViewer.panEnabled, isFalse);
    expect(cubit.state.zoomEnabled, isFalse);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(cubit.state.zoomEnabled, isTrue);

    final interactiveViewerAfter = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(interactiveViewerAfter.panEnabled, isTrue);
  });

  testWidgets('ChartContentList wraps chart in InteractiveViewer when zoomed', (
    WidgetTester tester,
  ) async {
    final cubit = ChartCubit(repository: _FakeChartRepository())
      ..setZoomEnabled(isEnabled: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: ChartContentList(
              l10n: AppLocalizationsEn(),
              points: samplePoints,
              dateFormat: format,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(InteractiveViewer), findsOneWidget);
  });

  testWidgets('ChartLoadingList shows skeleton placeholders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ChartLoadingList())),
    );

    expect(find.byType(CommonCard), findsNWidgets(2));
  });

  testWidgets('ChartLineGraph builds LineChart with provided points', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChartLineGraph(
            points: samplePoints,
            dateFormat: format,
            zoomEnabled: false,
          ),
        ),
      ),
    );

    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('ChartLineGraph preserves all input points in chart data', (
    WidgetTester tester,
  ) async {
    final List<ChartPoint> manyPoints = List<ChartPoint>.generate(
      400,
      (final i) => ChartPoint(
        date: DateTime.utc(2024, 1, 1).add(Duration(days: i)),
        value: i.toDouble(),
      ),
      growable: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChartLineGraph(
            points: manyPoints,
            dateFormat: format,
            zoomEnabled: false,
          ),
        ),
      ),
    );

    final LineChart lineChart = tester.widget<LineChart>(
      find.byType(LineChart),
    );
    expect(
      lineChart.data.lineBarsData.single.spots,
      hasLength(manyPoints.length),
    );
  });
}

class _FakeChartRepository extends ChartRepository {
  const _FakeChartRepository();

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async => const <ChartPoint>[];
}
