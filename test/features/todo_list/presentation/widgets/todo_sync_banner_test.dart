import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_sync_banner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPendingSyncRepository extends Mock
    implements PendingSyncRepository {}

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
    late _MockPendingSyncRepository pendingRepository;
    var getPendingOperationsCalls = 0;

    setUp(() {
      pendingRepository = _MockPendingSyncRepository();
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer((_) async {
        getPendingOperationsCalls += 1;
        return const <SyncOperation>[];
      });
    });

    Widget buildWidget({final SyncStatusCubit? cubit}) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: cubit == null
            ? TodoSyncBanner(pendingRepository: pendingRepository)
            : BlocProvider<SyncStatusCubit>.value(
                value: cubit,
                child: TodoSyncBanner(pendingRepository: pendingRepository),
              ),
      ),
    );

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
      final SyncStatusCubit cubit = SyncStatusCubit(
        networkStatusService: _FakeNetworkStatusService(),
        coordinator: coordinator,
      );

      addTearDown(() async {
        await cubit.close();
        await coordinator.dispose();
      });

      await tester.pumpWidget(buildWidget(cubit: cubit));
      await tester.pump();
      await tester.pumpWidget(buildWidget(cubit: cubit));
      await tester.pump();

      expect(coordinator.ensureStartedCalls, 1);
      expect(getPendingOperationsCalls, greaterThanOrEqualTo(1));
    });
  });
}
