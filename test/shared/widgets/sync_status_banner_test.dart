import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/widgets/sync_status_banner.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNetworkStatusService implements NetworkStatusService {
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
}

class _FakeBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
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
    flushCount += 1;
  }

  void emit(final SyncStatus next) {
    status = next;
    _controller.add(next);
  }
}

void main() {
  group('SyncStatusBanner', () {
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
        child: const Scaffold(body: SyncStatusBanner()),
      ),
    );

    testWidgets('renders safely without SyncStatusCubit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SyncStatusBanner()),
        ),
      );
      await tester.pump();

      expect(find.byType(SyncStatusBanner), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows localized degraded state and retries on tap', (
      tester,
    ) async {
      coordinator.status = SyncStatus.degraded;
      coordinator.emit(SyncStatus.degraded);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(SyncStatusBanner)),
      );
      expect(find.text(l10n.syncStatusDegradedTitle), findsOneWidget);
      expect(find.text(l10n.syncStatusDegradedMessage), findsOneWidget);

      await tester.tap(find.text(l10n.appInfoRetryButtonLabel));
      await tester.pump();

      expect(coordinator.flushCount, 1);
    });
  });
}
