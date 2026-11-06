import 'dart:async';

import 'package:flutter_bloc_app/features/carrier_line_demo/data/stub_carrier_realtime_client.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/data/stub_line_status_repository.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_connection_status.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_item.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_repository.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/line_status.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/presentation/cubit/carrier_line_cubit.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/no_op_fcm_messaging_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeInboxRepository implements CarrierInboxRepository {
  _FakeInboxRepository({this.seedGate, this.seedError});

  final Completer<void>? seedGate;
  final Object? seedError;
  final StreamController<List<CarrierInboxItem>> _controller =
      StreamController<List<CarrierInboxItem>>.broadcast();
  final List<CarrierInboxItem> _items = <CarrierInboxItem>[];
  bool seeded = false;
  int watchListenCount = 0;

  @override
  Future<List<CarrierInboxItem>> fetchAll() async =>
      List<CarrierInboxItem>.from(_items);

  @override
  Stream<List<CarrierInboxItem>> watchAll() {
    watchListenCount += 1;
    return Stream<List<CarrierInboxItem>>.multi((controller) async {
      controller.add(List<CarrierInboxItem>.from(_items));
      final StreamSubscription<List<CarrierInboxItem>> sub = _controller.stream
          .listen(
            controller.add,
            onError: controller.addError,
            onDone: controller.close,
          );
      controller.onCancel = () async {
        await sub.cancel();
      };
    });
  }

  @override
  Future<void> save(CarrierInboxItem item) async {
    _items
      ..removeWhere((CarrierInboxItem row) => row.id == item.id)
      ..add(item);
    _controller.add(List<CarrierInboxItem>.from(_items));
  }

  @override
  Future<void> markRead(String id) async {
    final int index = _items.indexWhere((CarrierInboxItem row) => row.id == id);
    if (index == -1) {
      return;
    }
    _items[index] = _items[index].copyWith(isUnread: false);
    _controller.add(List<CarrierInboxItem>.from(_items));
  }

  @override
  Future<void> ensureSeeded() async {
    final Completer<void>? gate = seedGate;
    if (gate != null) {
      await gate.future;
    }
    final Object? error = seedError;
    if (error != null) {
      throw error;
    }
    seeded = true;
    if (_items.isNotEmpty) {
      return;
    }
    await save(
      CarrierInboxItem(
        id: 'seed',
        kind: CarrierInboxKind.message,
        peerLabel: 'Seed',
        preview: 'Hello',
        occurredAt: DateTime.utc(2026, 1, 1),
        isUnread: true,
      ),
    );
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  test(
    'acceptance: start seeds inbox, loads fixture, connects stream',
    () async {
      final _FakeInboxRepository inbox = _FakeInboxRepository();
      final StubCarrierRealtimeClient realtime = StubCarrierRealtimeClient(
        connectDelay: Duration.zero,
      );
      final CarrierLineCubit cubit = CarrierLineCubit(
        inboxRepository: inbox,
        realtimeClient: realtime,
        lineStatusRepository: const StubLineStatusRepository(),
        fcmMessagingService: NoOpFcmMessagingService(),
      );

      await cubit.start();
      await Future<void>.delayed(Duration.zero);

      expect(inbox.seeded, isTrue);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.inbox, hasLength(1));
      expect(cubit.state.lineStatus.esim, LineLifecycleStatus.active);

      await cubit.connectRealtime();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.connection, CarrierConnectionStatus.connected);

      await cubit.disconnectRealtime();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.connection, CarrierConnectionStatus.disconnected);

      await cubit.markRead('seed');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.inbox.single.isUnread, isFalse);

      await cubit.close();
      await inbox.dispose();
    },
  );

  test('acceptance: dispose mid-connect does not emit after close', () async {
    final _FakeInboxRepository inbox = _FakeInboxRepository();
    final StubCarrierRealtimeClient realtime = StubCarrierRealtimeClient(
      connectDelay: const Duration(milliseconds: 50),
    );
    final CarrierLineCubit cubit = CarrierLineCubit(
      inboxRepository: inbox,
      realtimeClient: realtime,
      lineStatusRepository: const StubLineStatusRepository(),
      fcmMessagingService: NoOpFcmMessagingService(),
    );
    await cubit.start();
    final Future<void> connecting = cubit.connectRealtime();
    await cubit.close();
    await connecting.timeout(const Duration(milliseconds: 200));
    expect(cubit.isClosed, isTrue);
    await inbox.dispose();
  });

  test('acceptance: disconnect mid-connect settles connect future', () async {
    final StubCarrierRealtimeClient realtime = StubCarrierRealtimeClient(
      connectDelay: const Duration(milliseconds: 80),
    );
    final Future<void> connecting = realtime.connect();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await realtime.disconnect();
    await connecting.timeout(const Duration(milliseconds: 100));
    expect(realtime.currentStatus, CarrierConnectionStatus.disconnected);
    await realtime.dispose();
  });

  test('acceptance: simulated failure then retry reconnects', () async {
    final _FakeInboxRepository inbox = _FakeInboxRepository();
    final StubCarrierRealtimeClient realtime = StubCarrierRealtimeClient(
      connectDelay: Duration.zero,
    );
    final CarrierLineCubit cubit = CarrierLineCubit(
      inboxRepository: inbox,
      realtimeClient: realtime,
      lineStatusRepository: const StubLineStatusRepository(),
      fcmMessagingService: NoOpFcmMessagingService(),
    );
    await cubit.start();
    await Future<void>.delayed(Duration.zero);

    realtime.fail('simulated transport fault');
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.connection, CarrierConnectionStatus.error);
    expect(cubit.state.connectionError, 'simulated transport fault');

    await cubit.connectRealtime();
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.connection, CarrierConnectionStatus.connected);
    expect(cubit.state.connectionError, isNull);

    await cubit.close();
    await inbox.dispose();
  });

  test(
    'regression: delayed start aborted by close does not attach watches',
    () async {
      final Completer<void> seedGate = Completer<void>();
      final _FakeInboxRepository inbox = _FakeInboxRepository(
        seedGate: seedGate,
      );
      final StubCarrierRealtimeClient realtime = StubCarrierRealtimeClient(
        connectDelay: Duration.zero,
      );
      final CarrierLineCubit cubit = CarrierLineCubit(
        inboxRepository: inbox,
        realtimeClient: realtime,
        lineStatusRepository: const StubLineStatusRepository(),
        fcmMessagingService: NoOpFcmMessagingService(),
      );

      final Future<void> starting = cubit.start();
      await Future<void>.delayed(Duration.zero);
      await cubit.close();
      seedGate.complete();
      await starting.timeout(const Duration(milliseconds: 200));

      expect(cubit.isClosed, isTrue);
      expect(inbox.watchListenCount, 0);
      await inbox.dispose();
    },
  );

  test(
    'regression: seed failure still allows connect/disconnect updates',
    () async {
      final _FakeInboxRepository inbox = _FakeInboxRepository(
        seedError: StateError('seed boom'),
      );
      final StubCarrierRealtimeClient realtime = StubCarrierRealtimeClient(
        connectDelay: Duration.zero,
      );
      final CarrierLineCubit cubit = CarrierLineCubit(
        inboxRepository: inbox,
        realtimeClient: realtime,
        lineStatusRepository: const StubLineStatusRepository(),
        fcmMessagingService: NoOpFcmMessagingService(),
      );

      await cubit.start();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.errorMessage, contains('seed boom'));
      expect(cubit.state.isLoading, isFalse);

      await cubit.connectRealtime();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.connection, CarrierConnectionStatus.connected);

      await cubit.disconnectRealtime();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.connection, CarrierConnectionStatus.disconnected);

      await cubit.close();
      await inbox.dispose();
    },
  );
}
