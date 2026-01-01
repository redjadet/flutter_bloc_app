import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_sync_banner.dart';
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
  int flushCount = 0;

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
  Future<void> flush() async {
    flushCount++;
    emit(SyncStatus.syncing);
    emit(SyncStatus.idle);
  }

  void emit(final SyncStatus newStatus) {
    status = newStatus;
    _controller.add(newStatus);
  }
}

void main() {
  group('ProfileSyncBanner', () {
    late _FakeNetworkStatusService networkService;
    late _FakeBackgroundSyncCoordinator coordinator;
    late SyncStatusCubit syncCubit;

    setUp(() {
      networkService = _FakeNetworkStatusService();
      coordinator = _FakeBackgroundSyncCoordinator();
      syncCubit = SyncStatusCubit(
        networkStatusService: networkService,
        coordinator: coordinator,
      );
    });

    tearDown(() async {
      await syncCubit.close();
      await networkService.dispose();
      await coordinator.dispose();
    });

    Widget buildSubject() => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<SyncStatusCubit>.value(
        value: syncCubit,
        child: const Scaffold(body: ProfileSyncBanner()),
      ),
    );

    testWidgets('hides when online and idle', (tester) async {
      networkService.status = NetworkStatus.online;
      coordinator.status = SyncStatus.idle;

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(ProfileSyncBanner), findsOneWidget);
      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(ProfileSyncBanner)),
      );
      expect(find.text(l10n.syncStatusOfflineTitle), findsNothing);
      expect(find.text(l10n.syncStatusSyncingTitle), findsNothing);
    });

    testWidgets('shows offline banner', (tester) async {
      networkService.status = NetworkStatus.offline;
      coordinator.status = SyncStatus.idle;
      networkService.emit(NetworkStatus.offline);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(ProfileSyncBanner)),
      );
      expect(find.text(l10n.syncStatusOfflineTitle), findsOneWidget);
      expect(find.text(l10n.syncStatusOfflineMessage(0)), findsOneWidget);
    });

    testWidgets('shows syncing banner', (tester) async {
      networkService.status = NetworkStatus.online;
      coordinator.status = SyncStatus.syncing;
      coordinator.emit(SyncStatus.syncing);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(ProfileSyncBanner)),
      );
      expect(find.text(l10n.syncStatusSyncingTitle), findsOneWidget);
      expect(find.text(l10n.syncStatusSyncingMessage(0)), findsOneWidget);
    });

    testWidgets('updates when status changes after build', (tester) async {
      networkService.status = NetworkStatus.online;
      coordinator.status = SyncStatus.idle;

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(ProfileSyncBanner)),
      );
      expect(find.text(l10n.syncStatusOfflineTitle), findsNothing);

      await tester.runAsync(() async {
        networkService.emit(NetworkStatus.offline);
        await syncCubit.stream.firstWhere(
          (final SyncStatusState state) =>
              state.networkStatus == NetworkStatus.offline,
        );
      });
      await tester.pumpAndSettle();

      expect(find.text(l10n.syncStatusOfflineTitle), findsOneWidget);

      await tester.runAsync(() async {
        networkService.emit(NetworkStatus.online);
        await syncCubit.stream.firstWhere(
          (final SyncStatusState state) =>
              state.networkStatus == NetworkStatus.online,
        );
        coordinator.emit(SyncStatus.syncing);
        await syncCubit.stream.firstWhere(
          (final SyncStatusState state) =>
              state.syncStatus == SyncStatus.syncing,
        );
      });
      await tester.pumpAndSettle();

      expect(find.text(l10n.syncStatusSyncingTitle), findsOneWidget);
    });

    testWidgets('sync now button triggers flush when enabled', (tester) async {
      networkService.status = NetworkStatus.offline;
      coordinator.status = SyncStatus.idle;
      networkService.emit(NetworkStatus.offline);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(ProfileSyncBanner)),
      );

      await tester.tap(find.text(l10n.syncStatusSyncNowButton));
      await tester.pump();

      expect(coordinator.flushCount, 1);
    });

    testWidgets('sync now button works while offline banner visible', (
      tester,
    ) async {
      networkService.status = NetworkStatus.offline;
      coordinator.status = SyncStatus.idle;
      networkService.emit(NetworkStatus.offline);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(ProfileSyncBanner)),
      );
      await tester.tap(find.text(l10n.syncStatusSyncNowButton));
      await tester.pump();

      expect(coordinator.flushCount, 1);
    });
  });
}
