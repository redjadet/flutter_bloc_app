import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test_harness.dart';
import 'perf_charts_traces.dart';
import 'perf_helpers.dart';
import 'perf_repos.dart';

/// Captures frame timing artifacts using `traceAction()` and stores them in
/// `IntegrationTestWidgetsFlutterBinding.reportData`.
///
/// The runner can then persist `integration_response_data.json` to a stable
/// location under `artifacts/perf/`.
void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  registerIntegrationHarness();

  group('Perf smoke flows', () {
    testWidgets('captures todo list add flow trace', (final tester) async {
      await configureIntegrationTestDependencies();
      await overrideChartRepositoryForPerf(pointCount: 400);
      await overrideTodoRepositoryForPerf(itemCount: 250);
      await launchTestApp(tester);

      // NOTE: We intentionally rely on the `reportKey` output written by
      // `traceAction()` into `binding.reportData` so the host runner can persist
      // the results without needing device filesystem access.
      await binding.traceAction(
        () async {
          await timelineTask('perf.todo.open', () async {
            await openExampleDestination(tester, 'Todo List Demo');
          });
          final Finder addTodoButton = findAdaptiveButtonByText('Add todo');
          await pumpUntilFound(tester, addTodoButton);

          await timelineTask('perf.todo.open_add_dialog', () async {
            await tapAndPump(tester, addTodoButton);
          });
          final Finder saveButton = findDialogButtonByText('Save');
          await pumpUntilFound(tester, saveButton);

          final Finder titleField = findDialogTextField();
          await timelineTask('perf.todo.fill_and_save', () async {
            await tester.ensureVisible(titleField);
            await tester.enterText(titleField, 'Perf trace todo 0');
            await tester.pump(const Duration(milliseconds: 100));
            await tapAndPump(tester, findDialogCheckbox());
            await tapAndPump(tester, saveButton);
            await pumpUntilAbsent(tester, findDialog());
            await pumpUntilFound(tester, find.text('Perf trace todo 0'));
          });

          // Longer scroll sequence to better surface list/raster jank.
          await timelineTask('perf.todo.scroll.long', () async {
            final Finder scrollTarget = findScrollTarget(tester);
            for (int i = 0; i < 4; i++) {
              await tester.fling(
                scrollTarget,
                const Offset(0, -700),
                1600,
                warnIfMissed: false,
              );
              await tester.pump(const Duration(milliseconds: 300));
            }
          });
          await pumpSettleWithin(tester, timeout: const Duration(seconds: 5));
        },
        reportKey: 'todo_list_add_trace',
      );

      await binding.traceAction(
        () async {
          await timelineTask('perf.todo.zoom.prep', () async {
            await restartTestApp(tester);
            await openExampleDestination(tester, 'Todo List Demo');
            await pumpSettleWithin(tester, timeout: const Duration(seconds: 4));
          });

          await timelineTask('perf.todo.zoom.scroll', () async {
            final Finder scrollTarget = findScrollTarget(tester);
            for (int i = 0; i < 6; i++) {
              await tester.fling(
                scrollTarget,
                const Offset(0, -900),
                1900,
                warnIfMissed: false,
              );
              await tester.pump(const Duration(milliseconds: 200));
            }
          });
          await pumpSettleWithin(tester, timeout: const Duration(seconds: 4));
        },
        reportKey: 'todo_list_scroll_zoom_trace',
      );

      await binding.traceAction(
        () async {
          await restartTestApp(tester);

          await timelineTask('perf.chat.open', () async {
            await openExampleDestination(tester, 'Chat List Demo');
            await pumpUntilFound(tester, find.text('Conversation history'));
          });

          // Longer scroll sequence to better surface list/raster jank.
          await timelineTask('perf.chat.scroll.long', () async {
            final Finder scrollTarget = findScrollTarget(tester);
            for (int i = 0; i < 6; i++) {
              await tester.fling(
                scrollTarget,
                const Offset(0, -900),
                1800,
                warnIfMissed: false,
              );
              await tester.pump(const Duration(milliseconds: 250));
            }
          });
          await pumpSettleWithin(tester, timeout: const Duration(seconds: 6));
        },
        reportKey: 'chat_list_scroll_trace',
      );

      await binding.traceAction(
        () async {
          await timelineTask('perf.chat.zoom.prep', () async {
            await restartTestApp(tester);
            await openExampleDestination(tester, 'Chat List Demo');
            await pumpUntilFound(tester, find.text('Conversation history'));
            await pumpSettleWithin(tester);
          });

          await timelineTask('perf.chat.zoom.scroll', () async {
            final Finder scrollTarget = findScrollTarget(tester);
            for (int i = 0; i < 10; i++) {
              await tester.fling(
                scrollTarget,
                const Offset(0, -700),
                2000,
                warnIfMissed: false,
              );
              await tester.pump(const Duration(milliseconds: 160));
            }
          });
          await pumpSettleWithin(tester, timeout: const Duration(seconds: 4));
        },
        reportKey: 'chat_list_scroll_zoom_trace',
      );

      await binding.traceAction(
        () async {
          await timelineTask('perf.scapes.open', () async {
            await restartTestApp(tester);
            await openExampleDestination(tester, 'Scapes Demo');
            await pumpUntilFound(tester, find.text('Library / Scapes'));
            await pumpSettleWithin(tester, timeout: const Duration(seconds: 6));
          });

          await timelineTask('perf.scapes.scroll.long', () async {
            final Finder scrollTarget = findScrollTarget(tester);
            for (int i = 0; i < 10; i++) {
              await tester.fling(
                scrollTarget,
                const Offset(0, -900),
                2000,
                warnIfMissed: false,
              );
              await tester.pump(const Duration(milliseconds: 220));
            }
          });
          await pumpSettleWithin(tester, timeout: const Duration(seconds: 6));
        },
        reportKey: 'scapes_grid_scroll_trace',
      );

      await binding.traceAction(
        () async {
          await restartTestApp(tester);

          await timelineTask('perf.charts.open', () async {
            await openOverflowDestination(tester, 'Open charts');
            await pumpUntilFound(tester, find.text('Bitcoin Price (USD)'));
          });

          // Scroll through the chart screen to capture UI/raster work.
          await timelineTask('perf.charts.scroll.long', () async {
            final Finder scrollTarget = findScrollTarget(tester);
            for (int i = 0; i < 5; i++) {
              await tester.fling(
                scrollTarget,
                const Offset(0, -800),
                1700,
                warnIfMissed: false,
              );
              await tester.pump(const Duration(milliseconds: 250));
            }
          });

          // Pull-to-refresh style fling (downwards) to include overscroll/refresh work.
          await timelineTask('perf.charts.refresh.gesture', () async {
            final Finder scrollTarget = findScrollTarget(tester);
            await tester.fling(
              scrollTarget,
              const Offset(0, 500),
              1100,
              warnIfMissed: false,
            );
            await tester.pump(const Duration(milliseconds: 500));
          });
          await pumpSettleWithin(tester, timeout: const Duration(seconds: 6));
        },
        reportKey: 'charts_scroll_refresh_trace',
      );

      await binding.traceAction(
        () async {
          await timelineTask('perf.charts.zoom.prep', () async {
            await restartTestApp(tester);
            await openOverflowDestination(tester, 'Open charts');
            await pumpUntilFound(tester, find.text('Bitcoin Price (USD)'));
            await pumpSettleWithin(tester);
          });

          await timelineTask('perf.charts.zoom.scroll', () async {
            final Finder scrollTarget = findScrollTarget(tester);
            for (int i = 0; i < 8; i++) {
              await tester.fling(
                scrollTarget,
                const Offset(0, -650),
                2100,
                warnIfMissed: false,
              );
              await tester.pump(const Duration(milliseconds: 180));
            }
          });

          await timelineTask('perf.charts.zoom.refresh', () async {
            final Finder scrollTarget = findScrollTarget(tester);
            await tester.fling(
              scrollTarget,
              const Offset(0, 520),
              1200,
              warnIfMissed: false,
            );
            await tester.pump(const Duration(milliseconds: 650));
          });
          await pumpSettleWithin(tester, timeout: const Duration(seconds: 5));
        },
        reportKey: 'charts_scroll_refresh_zoom_trace',
      );

      await captureChartModeIsolationTraces(binding: binding, tester: tester);

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!.addAll(<String, dynamic>{
        'meta.todo_list_add_trace.note':
            'Timeline events are available via the integration_test report data for reportKey=todo_list_add_trace.',
        'meta.todo_list_add_trace.flutter': '3.41.5',
        'meta.todo_list_scroll_zoom_trace.note':
            'Zoomed trace for isolating list scrolling pipeline spikes.',
        'meta.todo_list_scroll_zoom_trace.flutter': '3.41.5',
        'meta.chat_list_scroll_trace.note':
            'Timeline events are available via the integration_test report data for reportKey=chat_list_scroll_trace.',
        'meta.chat_list_scroll_trace.flutter': '3.41.5',
        'meta.chat_list_scroll_zoom_trace.note':
            'Zoomed trace for isolating list scrolling pipeline spikes.',
        'meta.chat_list_scroll_zoom_trace.flutter': '3.41.5',
        'meta.scapes_grid_scroll_trace.note':
            'Image-heavy grid scroll trace (network images + TextPainter sizing).',
        'meta.scapes_grid_scroll_trace.flutter': '3.41.5',
        'meta.charts_scroll_refresh_trace.note':
            'Timeline events are available via the integration_test report data for reportKey=charts_scroll_refresh_trace.',
        'meta.charts_scroll_refresh_trace.flutter': '3.41.5',
        'meta.charts_scroll_refresh_zoom_trace.note':
            'Zoomed trace for isolating scroll/refresh pipeline spikes.',
        'meta.charts_scroll_refresh_zoom_trace.flutter': '3.41.5',
        ...chartModeIsolationMeta(),
      });

      // Persistable output for repo scripts: emit a single-line JSON blob that
      // host-side tooling can extract from the `flutter test` logs.
      //
      // Keep this marker stable; it is parsed by `tool/capture_perf_trace.sh`.
      // ignore: avoid_print
      print(
        '__PERF_REPORT_DATA__=${jsonEncode(binding.reportData)}',
      );

      await tearDownIntegrationTestDependencies();
    });
  });
}
