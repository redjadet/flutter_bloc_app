import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_sync_banner.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_helpers.dart';

class _FakeTodoRepository
    with TodoRepositoryNoPendingSync
    implements TodoRepository {
  _FakeTodoRepository();

  int pendingCount = 0;

  @override
  Future<void> clearCompleted() async {}

  @override
  Future<void> delete(final String id) async {}

  @override
  Future<List<TodoItem>> fetchAll() async => const <TodoItem>[];

  @override
  Future<void> save(final TodoItem item) async {}

  @override
  Stream<List<TodoItem>> watchAll() => const Stream<List<TodoItem>>.empty();

  @override
  Future<int> pendingSyncOperationCount({DateTime? now}) async => pendingCount;
}

class _FakeNetworkStatusService implements NetworkStatusService {
  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async => NetworkStatus.online;

  @override
  Future<void> dispose() async {}
}

class _FakeBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
  SyncStatus current = SyncStatus.idle;

  int ensureStartedCalls = 0;
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  @override
  SyncStatus get currentStatus => current;

  @override
  List<SyncCycleSummary> get history => const <SyncCycleSummary>[];

  @override
  SyncCycleSummary? get latestSummary => null;

  @override
  Stream<SyncCycleSummary> get summaryStream =>
      const Stream<SyncCycleSummary>.empty();

  @override
  Stream<SyncStatus> get statusStream => _statusController.stream;

  @override
  Future<void> dispose() async {
    await _statusController.close();
  }

  @override
  Future<void> ensureStarted() async {
    ensureStartedCalls += 1;
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> triggerFromFcm({final String? hint}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TodoSyncBanner', () {
    Widget buildWidget({
      final SyncStatusCubit? syncCubit,
      final TodoListCubit? todoCubit,
    }) {
      final Widget banner = const TodoSyncBanner();
      final Widget body = syncCubit == null && todoCubit == null
          ? banner
          : MultiBlocProvider(
              providers: <BlocProvider<dynamic>>[
                if (syncCubit != null)
                  BlocProvider<SyncStatusCubit>.value(value: syncCubit),
                if (todoCubit != null)
                  BlocProvider<TodoListCubit>.value(value: todoCubit),
              ],
              child: banner,
            );

      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: body),
      );
    }

    testWidgets('renders safely without SyncStatusCubit', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byType(TodoSyncBanner), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('starts sync once from didChangeDependencies', (tester) async {
      final _FakeBackgroundSyncCoordinator coordinator =
          _FakeBackgroundSyncCoordinator();
      final SyncStatusCubit syncCubit = SyncStatusCubit(
        networkStatusService: _FakeNetworkStatusService(),
        coordinator: coordinator,
      );
      final TodoListCubit todoCubit = TodoListCubit(
        repository: _FakeTodoRepository(),
        timerService: FakeTimerService(),
      );

      addTearDown(() async {
        await syncCubit.close();
        await todoCubit.close();
        await coordinator.dispose();
      });

      await tester.pumpWidget(
        buildWidget(syncCubit: syncCubit, todoCubit: todoCubit),
      );
      await tester.pump();
      await tester.pumpWidget(
        buildWidget(syncCubit: syncCubit, todoCubit: todoCubit),
      );
      await tester.pump();

      expect(coordinator.ensureStartedCalls, 1);
    });
  });
}
