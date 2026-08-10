import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test_harness.dart';
import 'perf_helpers.dart';

/// Debug Timeline selection trace against a real Hive-backed TodoRepository.
///
/// Seeds ≥100 todos into the simulator Hive store, opens Todo List, and
/// records Timeline via [IntegrationTestWidgetsFlutterBinding.traceAction]
/// (same channel DevTools Performance uses for frame/build timelines).
void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  registerIntegrationHarness();

  testWidgets('todo list selection profile on Hive ≥100', (
    tester,
  ) async {
    await configureIntegrationTestDependencies();
    addTearDown(tearDownIntegrationTestDependencies);

    final TodoRepository repo = getIt<TodoRepository>();
    final List<TodoItem> existing = await repo.fetchAll();
    const int targetCount = 120;
    for (int i = existing.length; i < targetCount; i++) {
      await repo.save(TodoItem.create(title: 'Hive profile seed $i'));
    }
    final List<TodoItem> seeded = await repo.fetchAll();
    expect(seeded.length, greaterThanOrEqualTo(100));

    await launchTestApp(tester);

    await binding.traceAction(
      () async {
        await timelineTask('perf.todo.hive.open', () async {
          await openExampleDestination(tester, 'Todo List Demo');
          await pumpSettleWithin(tester, timeout: const Duration(seconds: 8));
        });

        final Finder firstCheckbox = find.byType(Checkbox).first;
        await pumpUntilFound(tester, firstCheckbox);

        await timelineTask('perf.todo.hive.select_one', () async {
          await tapAndPump(tester, firstCheckbox);
          await tester.pump(const Duration(milliseconds: 50));
        });

        await timelineTask('perf.todo.hive.deselect_one', () async {
          await tapAndPump(tester, firstCheckbox);
          await tester.pump(const Duration(milliseconds: 50));
        });

        await timelineTask('perf.todo.hive.select_toggle_burst', () async {
          for (int i = 0; i < 8; i++) {
            await tapAndPump(tester, firstCheckbox);
            await tester.pump(const Duration(milliseconds: 32));
          }
        });

        await timelineTask('perf.todo.hive.scroll', () async {
          final Finder scrollTarget = findScrollTarget(tester);
          for (int i = 0; i < 4; i++) {
            await tester.fling(
              scrollTarget,
              const Offset(0, -700),
              1600,
              warnIfMissed: false,
            );
            await tester.pump(const Duration(milliseconds: 250));
          }
        });

        await pumpSettleWithin(tester, timeout: const Duration(seconds: 5));
      },
      reportKey: 'todo_list_hive_selection_profile',
    );

    // Emit for tool/capture_perf_trace.sh scraper.
    // ignore: avoid_print
    print('__PERF_REPORT_DATA__=${jsonEncode(binding.reportData)}');
  });
}
