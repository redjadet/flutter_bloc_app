import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_sync_banner.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late MockPendingSyncRepository pendingRepository;
  late _TestBackgroundSyncCoordinator coordinator;
  late _TestNetworkStatusService networkStatusService;

  setUpAll(() {
    registerFallbackValue(DateTime.fromMillisecondsSinceEpoch(0));
  });

  setUp(() {
    pendingRepository = MockPendingSyncRepository();
    coordinator = _TestBackgroundSyncCoordinator();
    networkStatusService = _TestNetworkStatusService();
  });

  tearDown(() async {
    await networkStatusService.dispose();
    await coordinator.dispose();
  });

  SyncStatusCubit buildSyncStatusCubit() => SyncStatusCubit(
    networkStatusService: networkStatusService,
    coordinator: coordinator,
  );

  Widget buildTestWidget(final SyncStatusCubit cubit) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<SyncStatusCubit>(
      create: (_) => cubit,
      child: Scaffold(
        body: ChatSyncBanner(pendingRepository: pendingRepository),
      ),
    ),
  );

  testWidgets('does not render when online with no pending operations', (
    final WidgetTester tester,
  ) async {
    when(
      () => pendingRepository.getPendingOperations(now: any(named: 'now')),
    ).thenAnswer((_) async => <SyncOperation>[]);

    await tester.pumpWidget(buildTestWidget(buildSyncStatusCubit()));
    await tester.pump();

    expect(find.byType(AppMessage), findsNothing);
  });

  testWidgets('shows offline message and disables sync button', (
    final WidgetTester tester,
  ) async {
    when(
      () => pendingRepository.getPendingOperations(now: any(named: 'now')),
    ).thenAnswer(
      (_) async => <SyncOperation>[
        SyncOperation.create(
          entityType: 'chat_message',
          payload: const <String, dynamic>{},
          idempotencyKey: 'op-1',
        ),
      ],
    );

    final SyncStatusCubit cubit = buildSyncStatusCubit();
    networkStatusService.emit(NetworkStatus.offline);
    await tester.pumpWidget(buildTestWidget(cubit));
    await tester.pump();

    expect(find.byType(AppMessage), findsOneWidget);
    expect(cubit.state.networkStatus, NetworkStatus.offline);
    final Finder buttonFinder = find.text('Sync now');
    expect(buttonFinder, findsOneWidget);
    final _ButtonVariant button = _resolveButtonVariant(tester, buttonFinder);
    await tester.tap(button.finder);
    await tester.pump();
    expect(coordinator.flushCount, 0);
  });

  testWidgets('tapping sync now triggers coordinator flush', (
    final WidgetTester tester,
  ) async {
    when(
      () => pendingRepository.getPendingOperations(now: any(named: 'now')),
    ).thenAnswer(
      (_) async => <SyncOperation>[
        SyncOperation.create(
          entityType: 'chat_message',
          payload: const <String, dynamic>{},
          idempotencyKey: 'op-2',
        ),
      ],
    );

    await tester.pumpWidget(buildTestWidget(buildSyncStatusCubit()));
    await tester.pump();

    final Finder buttonFinder = find.text('Sync now');
    expect(buttonFinder, findsOneWidget);

    final _ButtonVariant button = _resolveButtonVariant(tester, buttonFinder);
    expect(button.isEnabled, isTrue);

    await tester.tap(button.finder);
    await tester.pump();

    expect(coordinator.flushCount, 1);
  });
}

class MockPendingSyncRepository extends Mock implements PendingSyncRepository {}

class _TestBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
  final StreamController<SyncStatus> _controller =
      StreamController<SyncStatus>.broadcast();
  SyncStatus _status = SyncStatus.idle;
  int flushCount = 0;

  void emitStatus(final SyncStatus status) {
    _status = status;
    _controller.add(status);
  }

  @override
  SyncStatus get currentStatus => _status;

  @override
  Stream<SyncStatus> get statusStream => _controller.stream;

  @override
  Stream<SyncCycleSummary> get summaryStream =>
      const Stream<SyncCycleSummary>.empty();

  @override
  List<SyncCycleSummary> get history => const <SyncCycleSummary>[];

  @override
  SyncCycleSummary? get latestSummary => null;

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<void> flush() async {
    flushCount++;
    emitStatus(SyncStatus.syncing);
    emitStatus(SyncStatus.idle);
  }

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}

class _TestNetworkStatusService implements NetworkStatusService {
  final StreamController<NetworkStatus> _controller =
      StreamController<NetworkStatus>.broadcast();
  NetworkStatus _status = NetworkStatus.online;

  void emit(final NetworkStatus status) {
    _status = status;
    _controller.add(status);
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<NetworkStatus> getCurrentStatus() async => _status;

  @override
  Stream<NetworkStatus> get statusStream => _controller.stream;
}

class _ButtonVariant {
  const _ButtonVariant({required this.finder, required this.isEnabled});

  final Finder finder;
  final bool isEnabled;
}

_ButtonVariant _resolveButtonVariant(
  final WidgetTester tester,
  final Finder textFinder,
) {
  final Finder cupertinoFinder = find.ancestor(
    of: textFinder,
    matching: find.byType(CupertinoButton),
  );
  if (cupertinoFinder.evaluate().isNotEmpty) {
    final CupertinoButton button = tester.widget<CupertinoButton>(
      cupertinoFinder,
    );
    return _ButtonVariant(
      finder: cupertinoFinder,
      isEnabled: button.onPressed != null,
    );
  }

  final Finder materialFinder = find.ancestor(
    of: textFinder,
    matching: find.byType(TextButton),
  );
  if (materialFinder.evaluate().isNotEmpty) {
    final TextButton button = tester.widget<TextButton>(materialFinder);
    return _ButtonVariant(
      finder: materialFinder,
      isEnabled: button.onPressed != null,
    );
  }
  throw StateError('Sync button widget not found');
}
