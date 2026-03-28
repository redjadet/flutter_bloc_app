import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_line_graph.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';

import '../test_harness.dart';
import 'perf_charts_toggle_harness.dart';
import 'perf_helpers.dart';

Future<void> captureChartModeIsolationTraces({
  required final IntegrationTestWidgetsFlutterBinding binding,
  required final WidgetTester tester,
}) async {
  // Minimal toggles (no app navigation): isolates InteractiveViewer vs fl_chart.
  await binding.traceAction(
    () async {
      final DateFormat dateFormat = DateFormat.Md('en_US');
      final List<ChartPoint> points = List<ChartPoint>.generate(
        400,
        (final i) => ChartPoint(
          date: DateTime.utc(2024).add(Duration(days: i)),
          value: (i % 100).toDouble(),
        ),
        growable: false,
      );

      await timelineTask('perf.charts.minimal_linechart.prep', () async {
        await tester.pumpWidget(
          MaterialApp(
            home: MinimalChartToggleHarness(
              childBuilder: (final context, {required final zoomEnabled}) =>
                  ChartLineGraph(
                    points: points,
                    dateFormat: dateFormat,
                    zoomEnabled: zoomEnabled,
                  ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
      });

      final Finder zoomSwitch = find.byType(SwitchListTile).first;
      await pumpUntilFound(tester, zoomSwitch);

      await timelineTask('perf.charts.minimal_linechart.toggle', () async {
        for (int i = 0; i < 12; i++) {
          await tapAndPump(
            tester,
            zoomSwitch,
            settle: const Duration(milliseconds: 150),
          );
          await tester.pump(const Duration(milliseconds: 60));
        }
      });
    },
    reportKey: 'charts_minimal_linechart_toggle_trace',
  );

  await binding.traceAction(
    () async {
      await timelineTask('perf.charts.minimal_placeholder.prep', () async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MinimalChartToggleHarness(
              childBuilder: buildPlaceholderChart,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
      });

      final Finder zoomSwitch = find.byType(SwitchListTile).first;
      await pumpUntilFound(tester, zoomSwitch);

      await timelineTask('perf.charts.minimal_placeholder.toggle', () async {
        for (int i = 0; i < 12; i++) {
          await tapAndPump(
            tester,
            zoomSwitch,
            settle: const Duration(milliseconds: 150),
          );
          await tester.pump(const Duration(milliseconds: 60));
        }
      });
    },
    reportKey: 'charts_minimal_placeholder_toggle_trace',
  );

  await binding.traceAction(
    () async {
      await timelineTask('perf.switch.no_subtree_change.prep', () async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MinimalChartToggleHarness(
              childBuilder: buildConstantChild,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
      });

      final Finder zoomSwitch = find.byType(SwitchListTile).first;
      await pumpUntilFound(tester, zoomSwitch);

      await timelineTask('perf.switch.no_subtree_change.toggle', () async {
        for (int i = 0; i < 12; i++) {
          await tapAndPump(
            tester,
            zoomSwitch,
            settle: const Duration(milliseconds: 150),
          );
          await tester.pump(const Duration(milliseconds: 60));
        }
      });
    },
    reportKey: 'switch_toggle_no_subtree_change_trace',
  );

  await binding.traceAction(
    () async {
      await timelineTask(
        'perf.charts.minimal_placeholder_no_iv.prep',
        () async {
          await tester.pumpWidget(
            const MaterialApp(
              home: MinimalChartToggleHarness(
                childBuilder: buildPlaceholderNoInteractiveViewer,
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 300));
        },
      );

      final Finder zoomSwitch = find.byType(SwitchListTile).first;
      await pumpUntilFound(tester, zoomSwitch);

      await timelineTask(
        'perf.charts.minimal_placeholder_no_iv.toggle',
        () async {
          for (int i = 0; i < 12; i++) {
            await tapAndPump(
              tester,
              zoomSwitch,
              settle: const Duration(milliseconds: 150),
            );
            await tester.pump(const Duration(milliseconds: 60));
          }
        },
      );
    },
    reportKey: 'charts_minimal_placeholder_no_iv_toggle_trace',
  );

  await binding.traceAction(
    () async {
      final LineChartData data = LineChartData(
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const <FlSpot>[
              FlSpot.zero,
              FlSpot(1, 1),
              FlSpot(2, 0.5),
              FlSpot(3, 2),
            ],
            belowBarData: BarAreaData(),
            dotData: const FlDotData(show: false),
          ),
        ],
      );

      await timelineTask('perf.charts.minimal_linechart_no_iv.prep', () async {
        await tester.pumpWidget(
          MaterialApp(
            home: MinimalChartToggleHarness(
              childBuilder: (final context, {required final zoomEnabled}) =>
                  BareLineChart(
                    data: data,
                  ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
      });

      final Finder zoomSwitch = find.byType(SwitchListTile).first;
      await pumpUntilFound(tester, zoomSwitch);

      await timelineTask(
        'perf.charts.minimal_linechart_no_iv.toggle',
        () async {
          for (int i = 0; i < 12; i++) {
            await tapAndPump(
              tester,
              zoomSwitch,
              settle: const Duration(milliseconds: 150),
            );
            await tester.pump(const Duration(milliseconds: 60));
          }
        },
      );
    },
    reportKey: 'charts_minimal_linechart_no_iv_toggle_trace',
  );

  // Chart-only: force repeated rebuilds/repaints by toggling the zoom switch.
  await binding.traceAction(
    () async {
      await timelineTask('perf.charts.chart_only.prep', () async {
        await restartTestApp(tester);
        await openOverflowDestination(tester, 'Open charts');
        await pumpUntilFound(tester, find.text('Bitcoin Price (USD)'));
        await pumpSettleWithin(tester);
      });

      final Finder zoomSwitch = find.byType(SwitchListTile).first;
      await pumpUntilFound(tester, zoomSwitch);

      await timelineTask('perf.charts.chart_only.toggle_only', () async {
        for (int i = 0; i < 12; i++) {
          await tapAndPump(
            tester,
            zoomSwitch,
            settle: const Duration(milliseconds: 150),
          );
          await tester.pump(const Duration(milliseconds: 60));
        }
      });
    },
    reportKey: 'charts_chart_only_zoom_trace',
  );

  // Zoom enabled + scroll: isolates InteractiveViewer mode + scroll paint.
  await binding.traceAction(
    () async {
      await timelineTask('perf.charts.zoom_on.prep', () async {
        await restartTestApp(tester);
        await openOverflowDestination(tester, 'Open charts');
        await pumpUntilFound(tester, find.text('Bitcoin Price (USD)'));
        await pumpSettleWithin(tester);
      });

      final Finder zoomSwitch = find.byType(SwitchListTile).first;
      await pumpUntilFound(tester, zoomSwitch);
      await setSwitchListTileValue(
        tester,
        switchTileFinder: zoomSwitch,
        value: true,
      );

      await timelineTask('perf.charts.zoom_on.scroll', () async {
        final Finder scrollTarget = findScrollTarget(tester);
        for (int i = 0; i < 6; i++) {
          await tester.fling(
            scrollTarget,
            const Offset(0, -300),
            1400,
            warnIfMissed: false,
          );
          await tester.pump(const Duration(milliseconds: 160));
        }
      });

      await pumpSettleWithin(tester, timeout: const Duration(seconds: 5));
    },
    reportKey: 'charts_zoom_enabled_scroll_trace',
  );

  // Zoom disabled + scroll: isolates tooltip/touch mode + scroll paint.
  await binding.traceAction(
    () async {
      await timelineTask('perf.charts.zoom_off.prep', () async {
        await restartTestApp(tester);
        await openOverflowDestination(tester, 'Open charts');
        await pumpUntilFound(tester, find.text('Bitcoin Price (USD)'));
        await pumpSettleWithin(tester);
      });

      final Finder zoomSwitch = find.byType(SwitchListTile).first;
      await pumpUntilFound(tester, zoomSwitch);
      await setSwitchListTileValue(
        tester,
        switchTileFinder: zoomSwitch,
        value: false,
      );

      await timelineTask('perf.charts.zoom_off.scroll', () async {
        final Finder scrollTarget = findScrollTarget(tester);
        for (int i = 0; i < 6; i++) {
          await tester.fling(
            scrollTarget,
            const Offset(0, -300),
            1400,
            warnIfMissed: false,
          );
          await tester.pump(const Duration(milliseconds: 160));
        }
      });

      await pumpSettleWithin(tester, timeout: const Duration(seconds: 5));
    },
    reportKey: 'charts_zoom_disabled_scroll_trace',
  );
}

Map<String, dynamic> chartModeIsolationMeta() => <String, dynamic>{
  'meta.charts_minimal_linechart_toggle_trace.note':
      'Minimal harness: toggles ChartLineGraph (isolates fl_chart vs InteractiveViewer).',
  'meta.charts_minimal_linechart_toggle_trace.flutter': '3.41.6',
  'meta.charts_minimal_placeholder_toggle_trace.note':
      'Minimal harness: toggles placeholder widget with InteractiveViewer (no fl_chart).',
  'meta.charts_minimal_placeholder_toggle_trace.flutter': '3.41.6',
  'meta.switch_toggle_no_subtree_change_trace.note':
      'Control: toggles SwitchListTile while rendering constant child.',
  'meta.switch_toggle_no_subtree_change_trace.flutter': '3.41.6',
  'meta.charts_minimal_placeholder_no_iv_toggle_trace.note':
      'Minimal harness: toggles placeholder widget without InteractiveViewer.',
  'meta.charts_minimal_placeholder_no_iv_toggle_trace.flutter': '3.41.6',
  'meta.charts_minimal_linechart_no_iv_toggle_trace.note':
      'Minimal harness: toggles bare LineChart without InteractiveViewer.',
  'meta.charts_minimal_linechart_no_iv_toggle_trace.flutter': '3.41.6',
  'meta.charts_chart_only_zoom_trace.note':
      'Chart-only toggle trace (isolates zoom-mode switching).',
  'meta.charts_chart_only_zoom_trace.flutter': '3.41.6',
  'meta.charts_zoom_enabled_scroll_trace.note':
      'Chart trace: zoom enabled + scroll (InteractiveViewer mode).',
  'meta.charts_zoom_enabled_scroll_trace.flutter': '3.41.6',
  'meta.charts_zoom_disabled_scroll_trace.note':
      'Chart trace: zoom disabled + scroll (touch/tooltip mode).',
  'meta.charts_zoom_disabled_scroll_trace.flutter': '3.41.6',
};
