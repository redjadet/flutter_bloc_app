import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/search/presentation/widgets/search_sync_banner.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNetworkStatusService implements NetworkStatusService {
  _FakeNetworkStatusService();

  NetworkStatus status = NetworkStatus.online;
  final StreamController<NetworkStatus> _controller =
      StreamController<NetworkStatus>.broadcast();

  @override
  Stream<NetworkStatus> get statusStream => _controller.stream;

  @override
  Future<NetworkStatus> getCurrentStatus() async => status;

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  void emit(final NetworkStatus newStatus) {
    status = newStatus;
    _controller.add(newStatus);
  }
}

class _FakeBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
  _FakeBackgroundSyncCoordinator();

  SyncStatus status = SyncStatus.idle;
  final StreamController<SyncStatus> _controller =
      StreamController<SyncStatus>.broadcast();

  @override
  Stream<SyncStatus> get statusStream => _controller.stream;

  @override
  SyncStatus get currentStatus => status;

  @override
  List<SyncCycleSummary> get history => const <SyncCycleSummary>[];

  @override
  Stream<SyncCycleSummary> get summaryStream =>
      const Stream<SyncCycleSummary>.empty();

  @override
  SyncCycleSummary? get latestSummary => null;

  @override
  Future<void> start() async {}

  @override
  Future<void> ensureStarted() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<void> flush() async {}

  void emit(final SyncStatus newStatus) {
    status = newStatus;
    _controller.add(newStatus);
  }
}

void main() {
  group('SearchSyncBanner', () {
    late _FakeNetworkStatusService networkService;
    late _FakeBackgroundSyncCoordinator coordinator;
    late SyncStatusCubit syncCubit;

    setUp(() {
      networkService = _FakeNetworkStatusService();
      coordinator = _FakeBackgroundSyncCoordinator();
      // Set initial status before creating cubit so it picks up the correct state
      networkService.status = NetworkStatus.online;
      coordinator.status = SyncStatus.idle;
      syncCubit = SyncStatusCubit(
        networkStatusService: networkService,
        coordinator: coordinator,
      );
    });

    tearDown(() {
      syncCubit.close();
      networkService.dispose();
      coordinator.dispose();
    });

    Widget buildSubject() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<SyncStatusCubit>.value(
          value: syncCubit,
          child: const Scaffold(body: SearchSyncBanner()),
        ),
      );
    }

    testWidgets('hides banner when online and not syncing', (tester) async {
      networkService.status = NetworkStatus.online;
      coordinator.status = SyncStatus.idle;

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(SearchSyncBanner), findsOneWidget);
      // Banner should render SizedBox.shrink when hidden
      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(SearchSyncBanner)),
      );
      expect(find.text(l10n.syncStatusOfflineTitle), findsNothing);
      expect(find.text(l10n.syncStatusSyncingTitle), findsNothing);
    });

    testWidgets('shows offline banner when network is offline', (tester) async {
      networkService.status = NetworkStatus.offline;
      coordinator.status = SyncStatus.idle;
      networkService.emit(NetworkStatus.offline);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(SearchSyncBanner)),
      );
      expect(find.text(l10n.syncStatusOfflineTitle), findsOneWidget);
      expect(find.text(l10n.syncStatusOfflineMessage(0)), findsOneWidget);
    });

    testWidgets('shows syncing banner when coordinator is syncing', (
      tester,
    ) async {
      networkService.status = NetworkStatus.online;
      coordinator.status = SyncStatus.syncing;
      coordinator.emit(SyncStatus.syncing);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(SearchSyncBanner)),
      );
      expect(find.text(l10n.syncStatusSyncingTitle), findsOneWidget);
      expect(find.text(l10n.syncStatusSyncingMessage(0)), findsOneWidget);
    });

    testWidgets('updates banner when network status changes', (tester) async {
      networkService.status = NetworkStatus.online;
      coordinator.status = SyncStatus.idle;
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle(); // Allow cubit to seed initial state

      // Initially hidden (online + idle)
      final AppLocalizations l10n1 = AppLocalizations.of(
        tester.element(find.byType(SearchSyncBanner)),
      );
      expect(find.text(l10n1.syncStatusOfflineTitle), findsNothing);

      await tester.runAsync(() async {
        networkService.emit(NetworkStatus.offline);
        await syncCubit.stream.firstWhere(
          (final SyncStatusState state) =>
              state.networkStatus == NetworkStatus.offline,
        );
      });
      await tester.pumpAndSettle(); // Allow stream event and rebuild

      // Verify cubit state updated
      expect(
        syncCubit.state.networkStatus,
        NetworkStatus.offline,
        reason: 'Cubit should receive network status stream events',
      );

      // Should show offline banner
      expect(find.text(l10n1.syncStatusOfflineTitle), findsOneWidget);

      // Go back online
      await tester.runAsync(() async {
        networkService.emit(NetworkStatus.online);
        await syncCubit.stream.firstWhere(
          (final SyncStatusState state) =>
              state.networkStatus == NetworkStatus.online,
        );
      });
      await tester.pumpAndSettle(); // Allow stream event and rebuild

      // Should hide again
      expect(find.text(l10n1.syncStatusOfflineTitle), findsNothing);
    });

    testWidgets('updates banner when sync status changes', (tester) async {
      networkService.status = NetworkStatus.online;
      coordinator.status = SyncStatus.idle;

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle(); // Allow cubit to seed initial state

      // Initially hidden (online + idle)
      final AppLocalizations l10n2 = AppLocalizations.of(
        tester.element(find.byType(SearchSyncBanner)),
      );
      expect(find.text(l10n2.syncStatusSyncingTitle), findsNothing);

      await tester.runAsync(() async {
        coordinator.emit(SyncStatus.syncing);
        await syncCubit.stream.firstWhere(
          (final SyncStatusState state) =>
              state.syncStatus == SyncStatus.syncing,
        );
      });
      await tester.pumpAndSettle(); // Allow stream event to propagate

      // Verify cubit state updated - if this fails, cubit isn't receiving events
      expect(
        syncCubit.state.syncStatus,
        SyncStatus.syncing,
        reason: 'Cubit should receive sync status stream events',
      );

      // Should show syncing banner
      expect(find.text(l10n2.syncStatusSyncingTitle), findsOneWidget);

      // Stop syncing
      await tester.runAsync(() async {
        coordinator.emit(SyncStatus.idle);
        await syncCubit.stream.firstWhere(
          (final SyncStatusState state) => state.syncStatus == SyncStatus.idle,
        );
      });
      await tester.pumpAndSettle(); // Allow stream event to propagate

      // Should hide again
      expect(find.text(l10n2.syncStatusSyncingTitle), findsNothing);
    });
  });
}
