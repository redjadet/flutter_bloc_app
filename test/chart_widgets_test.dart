import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_content_list.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_line_graph.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_loading_list.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  setUp(() {
    UI.resetScreenUtilReady();
  });

  final List<ChartPoint> samplePoints = <ChartPoint>[
    ChartPoint(date: DateTime.utc(2024, 1, 1), value: 42.0),
    ChartPoint(date: DateTime.utc(2024, 1, 2), value: 43.5),
  ];
  final DateFormat format = DateFormat('MMM d');

  testWidgets('ChartContentList renders chart and toggles zoom', (
    WidgetTester tester,
  ) async {
    bool zoomToggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChartContentList(
            l10n: AppLocalizationsEn(),
            points: samplePoints,
            dateFormat: format,
            zoomEnabled: false,
            onZoomChanged: (value) => zoomToggled = value,
          ),
        ),
      ),
    );

    expect(find.byType(ChartLineGraph), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsNothing);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(zoomToggled, isTrue);
  });

  testWidgets('ChartContentList wraps chart in InteractiveViewer when zoomed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChartContentList(
            l10n: AppLocalizationsEn(),
            points: samplePoints,
            dateFormat: format,
            zoomEnabled: true,
            onZoomChanged: (_) {},
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

    expect(find.byType(Container), findsWidgets);
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
}
