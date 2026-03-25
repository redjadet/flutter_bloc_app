import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/app_scope.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/responsive/responsive.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../test_helpers.dart' as test_helpers;

class _CountingBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
  int startCount = 0;
  int flushCount = 0;

  @override
  Stream<SyncStatus> get statusStream => const Stream<SyncStatus>.empty();

  @override
  SyncStatus get currentStatus => SyncStatus.idle;

  @override
  Stream<SyncCycleSummary> get summaryStream =>
      const Stream<SyncCycleSummary>.empty();

  @override
  SyncCycleSummary? get latestSummary => null;

  @override
  List<SyncCycleSummary> get history => const <SyncCycleSummary>[];

  @override
  Future<void> start() async {
    startCount += 1;
  }

  @override
  Future<void> ensureStarted() async {
    await start();
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> flush() async {
    flushCount += 1;
  }

  @override
  Future<void> triggerFromFcm({final String? hint}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    await test_helpers.setupTestDependencies();
  });

  tearDown(() async {
    await test_helpers.tearDownTestDependencies();
  });

  testWidgets('starts background sync only when requested', (
    WidgetTester tester,
  ) async {
    final coordinator = _CountingBackgroundSyncCoordinator();
    if (getIt.isRegistered<BackgroundSyncCoordinator>()) {
      getIt.unregister<BackgroundSyncCoordinator>();
    }
    getIt.registerSingleton<BackgroundSyncCoordinator>(coordinator);

    late void Function(VoidCallback) triggerRebuild;
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (final context, final state) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (final context, final setState) {
          triggerRebuild = setState;
          return AppScope(router: router);
        },
      ),
    );
    await tester.pump();

    expect(coordinator.startCount, 0);

    triggerRebuild(() {});
    await tester.pump();

    expect(coordinator.startCount, 0);

    final BuildContext context = tester.element(find.byType(ResponsiveScope));
    context.cubit<SyncStatusCubit>().ensureStarted();
    await tester.pump();

    expect(coordinator.startCount, 1);
  });

  testWidgets('debounces a single flush after app resumes', (
    WidgetTester tester,
  ) async {
    final coordinator = _CountingBackgroundSyncCoordinator();
    final test_helpers.FakeTimerService timerService =
        test_helpers.FakeTimerService();
    if (getIt.isRegistered<BackgroundSyncCoordinator>()) {
      getIt.unregister<BackgroundSyncCoordinator>();
    }
    if (getIt.isRegistered<TimerService>()) {
      getIt.unregister<TimerService>();
    }
    getIt.registerSingleton<BackgroundSyncCoordinator>(coordinator);
    getIt.registerSingleton<TimerService>(timerService);

    final GoRouter router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (final context, final state) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(AppScope(router: router));
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(coordinator.flushCount, 0);

    timerService.elapse(const Duration(milliseconds: 499));
    await tester.pump();
    expect(coordinator.flushCount, 0);

    timerService.elapse(const Duration(milliseconds: 1));
    await tester.pump();
    expect(coordinator.flushCount, 1);
  });
}
