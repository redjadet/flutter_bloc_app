import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/app_scope.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/shared/responsive/responsive.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../test_helpers.dart' as test_helpers;

class _CountingBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
  int startCount = 0;

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
  Future<void> flush() async {}
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
    context.read<SyncStatusCubit>().ensureStarted();
    await tester.pump();

    expect(coordinator.startCount, 1);
  });
}
