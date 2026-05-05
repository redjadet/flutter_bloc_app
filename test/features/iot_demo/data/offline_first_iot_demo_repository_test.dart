import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/offline_first_iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/persistent_iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/supabase_iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../../../test_helpers.dart' show FakeTimerService;

const String _testSupabaseUserId = 'test-supabase-user-id';

void main() {
  group('OfflineFirstIotDemoRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late PendingSyncRepository pendingRepository;
    late SyncableRepositoryRegistry registry;
    late _FakeSupabaseRemote remoteRepository;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('offline_iot_repo_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      pendingRepository = PendingSyncRepository(hiveService: hiveService);
      registry = SyncableRepositoryRegistry();
      remoteRepository = _FakeSupabaseRemote();
    });

    tearDown(() async {
      await pendingRepository.clear();
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    OfflineFirstIotDemoRepository buildRepository({
      SupabaseIotDemoRepository? remote,
      String? supabaseUserId,
      TimerService? timerService,
    }) => OfflineFirstIotDemoRepository(
      getCurrentSupabaseUserId: () => supabaseUserId ?? _testSupabaseUserId,
      getPersistentRepository: (final String id) => PersistentIotDemoRepository(
        hiveService: hiveService,
        supabaseUserId: id,
        timerService: timerService ?? FakeTimerService(),
      ),
      pendingSyncRepository: pendingRepository,
      registry: registry,
      timerService: timerService ?? FakeTimerService(),
      remoteRepository: remote,
    );

    test('watchDevices streams from local (empty when no devices)', () async {
      final OfflineFirstIotDemoRepository repo = buildRepository();
      final List<IotDevice> first = await repo.watchDevices().first;
      expect(first, isEmpty);
    });

    test(
      'watchDevices stays local and does not fetch remote on subscribe',
      () async {
        final _FakeSupabaseRemote remote = _FakeSupabaseRemote();
        final OfflineFirstIotDemoRepository repo = buildRepository(
          remote: remote,
        );
        const IotDevice localDevice = IotDevice(
          id: 'local-1',
          name: 'Local Device',
          type: IotDeviceType.light,
          toggledOn: true,
        );

        await repo.addDevice(localDevice);

        final List<IotDevice> first = await repo
            .watchDevices(IotDemoDeviceFilter.toggledOnOnly)
            .first;

        expect(first, <IotDevice>[localDevice]);
        expect(remote.fetchCallCount, 0);
      },
    );

    test(
      'watchDevices applies filter changes from local updates immediately',
      () async {
        final _FakeSupabaseRemote remote = _FakeSupabaseRemote();
        remote.devices = <IotDevice>[
          const IotDevice(
            id: 'd1',
            name: 'D1',
            type: IotDeviceType.light,
            toggledOn: false,
          ),
        ];
        final OfflineFirstIotDemoRepository seedRepo = buildRepository(
          remote: remote,
        );
        await seedRepo.pullRemote();

        // For this test we only care about local update propagation.
        // Use a repo with `remote: null` to avoid enqueue side-effects.
        final OfflineFirstIotDemoRepository repo = buildRepository();
        final List<IotDevice> before = await repo
            .watchDevices(IotDemoDeviceFilter.toggledOffOnly)
            .first
            .timeout(const Duration(seconds: 5));
        expect(before.single.id, 'd1');
        expect(before.single.toggledOn, isFalse);

        await repo.sendCommand('d1', const IotDeviceCommand.toggle());

        final List<IotDevice> after = await repo
            .watchDevices(IotDemoDeviceFilter.toggledOffOnly)
            .firstWhere((final list) => list.isEmpty)
            .timeout(const Duration(seconds: 5));
        expect(after, isEmpty);
      },
    );

    test('connect enqueues operation when remote is set', () async {
      final OfflineFirstIotDemoRepository repo = buildRepository(
        remote: remoteRepository,
      );
      await repo.connect('light-1');
      final List<SyncOperation> pending = await pendingRepository
          .getPendingOperations(now: DateTime.now().toUtc());
      expect(
        pending.any(
          (final op) =>
              op.entityType == 'iot_demo' &&
              op.payload['action'] == 'connect' &&
              op.payload['deviceId'] == 'light-1' &&
              op.payload['supabaseUserId'] == _testSupabaseUserId,
        ),
        isTrue,
      );
    });

    test('disconnect enqueues operation when remote is set', () async {
      final OfflineFirstIotDemoRepository repo = buildRepository(
        remote: remoteRepository,
      );
      await repo.disconnect('light-1');
      final List<SyncOperation> pending = await pendingRepository
          .getPendingOperations(now: DateTime.now().toUtc());
      expect(
        pending.any(
          (final op) =>
              op.entityType == 'iot_demo' &&
              op.payload['action'] == 'disconnect' &&
              op.payload['deviceId'] == 'light-1' &&
              op.payload['supabaseUserId'] == _testSupabaseUserId,
        ),
        isTrue,
      );
    });

    test('processOperation connect calls remote connect', () async {
      final OfflineFirstIotDemoRepository repo = buildRepository(
        remote: remoteRepository,
      );
      final SyncOperation op = SyncOperation.create(
        entityType: 'iot_demo',
        payload: <String, dynamic>{
          'deviceId': 'light-1',
          'action': 'connect',
          'supabaseUserId': _testSupabaseUserId,
        },
        idempotencyKey: 'test_connect_1',
      );
      await repo.processOperation(op);
      expect(remoteRepository.connectCalls, contains('light-1'));
    });

    test('processOperation disconnect calls remote disconnect', () async {
      final OfflineFirstIotDemoRepository repo = buildRepository(
        remote: remoteRepository,
      );
      final SyncOperation op = SyncOperation.create(
        entityType: 'iot_demo',
        payload: <String, dynamic>{
          'deviceId': 'thermostat-1',
          'action': 'disconnect',
          'supabaseUserId': _testSupabaseUserId,
        },
        idempotencyKey: 'test_disconnect_1',
      );
      await repo.processOperation(op);
      expect(remoteRepository.disconnectCalls, contains('thermostat-1'));
    });

    test('processOperation skips legacy op without supabaseUserId', () async {
      final OfflineFirstIotDemoRepository repo = buildRepository(
        remote: remoteRepository,
      );
      final SyncOperation op = SyncOperation.create(
        entityType: 'iot_demo',
        payload: <String, dynamic>{'deviceId': 'light-1', 'action': 'connect'},
        idempotencyKey: 'test_legacy_1',
      );
      await repo.processOperation(op);
      expect(remoteRepository.connectCalls, isEmpty);
    });

    test('addDevice enqueues operation when remote is set', () async {
      final OfflineFirstIotDemoRepository repo = buildRepository(
        remote: remoteRepository,
      );
      const device = IotDevice(
        id: 'new-light-1',
        name: 'New Light',
        type: IotDeviceType.light,
      );
      await repo.addDevice(device);
      final List<SyncOperation> pending = await pendingRepository
          .getPendingOperations(now: DateTime.now().toUtc());
      expect(
        pending.any(
          (final op) =>
              op.entityType == 'iot_demo' &&
              op.payload['action'] == 'add' &&
              op.payload['deviceId'] == 'new-light-1' &&
              op.payload['name'] == 'New Light' &&
              op.payload['supabaseUserId'] == _testSupabaseUserId,
        ),
        isTrue,
      );
      final List<IotDevice> local = await repo.watchDevices().first;
      expect(local, hasLength(1));
      expect(local.first.id, 'new-light-1');
    });

    test('addDevice throws for name exceeding max length', () async {
      final OfflineFirstIotDemoRepository repo = buildRepository(
        remote: remoteRepository,
      );
      final IotDevice device = IotDevice(
        id: 'new-light-1',
        name: 'x' * (iotDemoDeviceNameMaxLength + 1),
        type: IotDeviceType.light,
      );

      expect(() => repo.addDevice(device), throwsArgumentError);

      final List<IotDevice> local = await repo.watchDevices().first;
      expect(local, isEmpty);

      final List<SyncOperation> pending = await pendingRepository
          .getPendingOperations(now: DateTime.now().toUtc());
      expect(pending.any((final op) => op.payload['action'] == 'add'), isFalse);
    });

    test('addDevice does nothing when no user', () async {
      final OfflineFirstIotDemoRepository repo = OfflineFirstIotDemoRepository(
        getCurrentSupabaseUserId: () => null,
        getPersistentRepository: (final String id) =>
            PersistentIotDemoRepository(
              hiveService: hiveService,
              supabaseUserId: id,
              timerService: FakeTimerService(),
            ),
        pendingSyncRepository: pendingRepository,
        registry: registry,
        timerService: FakeTimerService(),
        remoteRepository: remoteRepository,
      );
      const device = IotDevice(
        id: 'new-light-1',
        name: 'New Light',
        type: IotDeviceType.light,
      );
      await repo.addDevice(device);
      final List<IotDevice> local = await repo.watchDevices().first;
      expect(local, isEmpty);
      final List<SyncOperation> pending = await pendingRepository
          .getPendingOperations(now: DateTime.now().toUtc());
      expect(pending.any((final op) => op.payload['action'] == 'add'), isFalse);
    });

    test('processOperation add calls remote addDevice', () async {
      final OfflineFirstIotDemoRepository repo = buildRepository(
        remote: remoteRepository,
      );
      final SyncOperation op = SyncOperation.create(
        entityType: 'iot_demo',
        payload: <String, dynamic>{
          'deviceId': 'new-sensor-1',
          'action': 'add',
          'name': 'Temp Sensor',
          'type': 'sensor',
          'toggledOn': false,
          'value': 22.5,
          'supabaseUserId': _testSupabaseUserId,
        },
        idempotencyKey: 'test_add_1',
      );
      await repo.processOperation(op);
      expect(remoteRepository.addDeviceCalls, hasLength(1));
      final IotDevice added = remoteRepository.addDeviceCalls.single;
      expect(added.id, 'new-sensor-1');
      expect(added.name, 'Temp Sensor');
      expect(added.type, IotDeviceType.sensor);
      expect(added.value, 22.5);
    });

    test('processOperation add skips when name exceeds max length', () async {
      final OfflineFirstIotDemoRepository repo = buildRepository(
        remote: remoteRepository,
      );
      final SyncOperation op = SyncOperation.create(
        entityType: 'iot_demo',
        payload: <String, dynamic>{
          'deviceId': 'new-dev-1',
          'action': 'add',
          'name': 'x' * (iotDemoDeviceNameMaxLength + 1),
          'type': 'light',
          'toggledOn': false,
          'value': 0,
          'supabaseUserId': _testSupabaseUserId,
        },
        idempotencyKey: 'test_add_long_name',
      );
      await repo.processOperation(op);
      expect(remoteRepository.addDeviceCalls, isEmpty);
    });

    test('processOperation skips op for different user', () async {
      final OfflineFirstIotDemoRepository repo = buildRepository(
        remote: remoteRepository,
      );
      final SyncOperation op = SyncOperation.create(
        entityType: 'iot_demo',
        payload: <String, dynamic>{
          'deviceId': 'light-1',
          'action': 'connect',
          'supabaseUserId': 'other-user-id',
        },
        idempotencyKey: 'test_other_user_1',
      );
      await repo.processOperation(op);
      expect(remoteRepository.connectCalls, isEmpty);
    });

    test('pullRemote fetches from remote and replaces local', () async {
      remoteRepository.devices = <IotDevice>[
        const IotDevice(
          id: 'remote-1',
          name: 'Remote Device',
          type: IotDeviceType.light,
        ),
      ];
      final OfflineFirstIotDemoRepository repo = buildRepository(
        remote: remoteRepository,
      );
      await repo.pullRemote();
      final List<IotDevice> list = await repo.watchDevices().first;
      expect(list, hasLength(1));
      expect(list.first.id, 'remote-1');
      expect(list.first.name, 'Remote Device');
    });

    test('pullRemote with empty remote replaces local with empty', () async {
      remoteRepository.devices = <IotDevice>[];
      final OfflineFirstIotDemoRepository repo = buildRepository(
        remote: remoteRepository,
      );
      await repo.pullRemote();
      final List<IotDevice> list = await repo.watchDevices().first;
      expect(list, isEmpty);
    });

    test(
      'pullRemote does not overwrite local when there are pending iot_demo ops',
      () async {
        const IotDevice localDevice = IotDevice(
          id: 'local-1',
          name: 'Local Device',
          type: IotDeviceType.light,
          toggledOn: true,
        );
        remoteRepository.devices = <IotDevice>[
          const IotDevice(
            id: 'remote-1',
            name: 'Stale Remote Device',
            type: IotDeviceType.plug,
          ),
        ];
        final OfflineFirstIotDemoRepository repo = buildRepository(
          remote: remoteRepository,
        );
        await repo.addDevice(localDevice);
        final List<IotDevice> beforePull = await repo.watchDevices().first;
        expect(beforePull, hasLength(1));
        expect(beforePull.first.id, 'local-1');

        await repo.pullRemote();

        final List<IotDevice> afterPull = await repo.watchDevices().first;
        expect(afterPull, hasLength(1));
        expect(afterPull.first.id, 'local-1');
        expect(afterPull.first.name, 'Local Device');
      },
    );

    test(
      'pullRemote seeds remote devices when local is empty despite pending iot_demo ops',
      () async {
        remoteRepository.devices = <IotDevice>[
          const IotDevice(
            id: 'remote-1',
            name: 'Remote Device',
            type: IotDeviceType.light,
          ),
        ];
        final OfflineFirstIotDemoRepository repo = buildRepository(
          remote: remoteRepository,
        );

        await pendingRepository.enqueue(
          SyncOperation.create(
            entityType: 'iot_demo',
            payload: <String, dynamic>{
              'deviceId': 'ghost-1',
              'action': 'connect',
              'supabaseUserId': _testSupabaseUserId,
            },
            idempotencyKey: 'pending_connect_1',
          ),
        );

        await repo.pullRemote();

        final List<IotDevice> list = await repo.watchDevices().first;
        expect(list, hasLength(1));
        expect(list.first.id, 'remote-1');
        expect(list.first.name, 'Remote Device');
      },
    );

    test(
      'setValue debounces: only one sync op after delay without change',
      () async {
        final FakeTimerService fakeTimer = FakeTimerService();
        remoteRepository.devices = <IotDevice>[
          IotDevice(
            id: 'thermostat-1',
            name: 'Thermostat',
            type: IotDeviceType.thermostat,
            value: 0.5,
          ),
        ];
        final OfflineFirstIotDemoRepository repo = buildRepository(
          remote: remoteRepository,
          timerService: fakeTimer,
        );
        await repo.pullRemote();
        await repo.sendCommand('thermostat-1', IotDeviceCommand.setValue(0.6));
        await repo.sendCommand('thermostat-1', IotDeviceCommand.setValue(0.7));
        await repo.sendCommand('thermostat-1', IotDeviceCommand.setValue(0.8));
        List<SyncOperation> pending = await pendingRepository
            .getPendingOperations(now: DateTime.now().toUtc());
        final int setValueOpsBefore = pending
            .where(
              (final op) =>
                  op.payload['kind'] == 'setValue' &&
                  op.payload['deviceId'] == 'thermostat-1',
            )
            .length;
        expect(setValueOpsBefore, 0);
        fakeTimer.elapse(OfflineFirstIotDemoRepository.setValueSyncDebounce);
        await Future<void>.delayed(Duration.zero);
        pending = await pendingRepository.getPendingOperations(
          now: DateTime.now().toUtc(),
        );
        final List<SyncOperation> setValueOps = pending
            .where(
              (final op) =>
                  op.payload['kind'] == 'setValue' &&
                  op.payload['deviceId'] == 'thermostat-1',
            )
            .toList();
        expect(setValueOps, hasLength(1));
        expect(setValueOps.single.payload['value'], 0.8);
      },
    );

    test(
      'debounced setValue keeps the original user id when auth changes before enqueue',
      () async {
        final FakeTimerService fakeTimer = FakeTimerService();
        String currentUserId = _testSupabaseUserId;
        remoteRepository.devices = <IotDevice>[
          const IotDevice(
            id: 'thermostat-1',
            name: 'Thermostat',
            type: IotDeviceType.thermostat,
            value: 0.5,
          ),
        ];
        final OfflineFirstIotDemoRepository repo =
            OfflineFirstIotDemoRepository(
              getCurrentSupabaseUserId: () => currentUserId,
              getPersistentRepository: (final String id) =>
                  PersistentIotDemoRepository(
                    hiveService: hiveService,
                    supabaseUserId: id,
                    timerService: fakeTimer,
                  ),
              pendingSyncRepository: pendingRepository,
              registry: registry,
              timerService: fakeTimer,
              remoteRepository: remoteRepository,
            );
        await repo.pullRemote();
        await repo.sendCommand('thermostat-1', IotDeviceCommand.setValue(0.7));

        currentUserId = 'other-user-id';
        fakeTimer.elapse(OfflineFirstIotDemoRepository.setValueSyncDebounce);
        await Future<void>.delayed(Duration.zero);

        final List<SyncOperation> pending = await pendingRepository
            .getPendingOperations(now: DateTime.now().toUtc());
        final SyncOperation setValueOp = pending.singleWhere(
          (final op) =>
              op.payload['kind'] == 'setValue' &&
              op.payload['deviceId'] == 'thermostat-1',
        );
        expect(setValueOp.payload['supabaseUserId'], _testSupabaseUserId);
      },
    );

    test('pullRemote coalesces per user instead of globally', () async {
      await pendingRepository.clear();
      String currentUserId = _testSupabaseUserId;
      final Completer<List<IotDevice>> firstFetchCompleter =
          Completer<List<IotDevice>>();
      final Completer<List<IotDevice>> secondFetchCompleter =
          Completer<List<IotDevice>>();
      int fetchIndex = 0;
      final _ControllableSupabaseRemote controllableRemote =
          _ControllableSupabaseRemote(
            fetchHandler: () {
              fetchIndex++;
              if (fetchIndex == 1) {
                return firstFetchCompleter.future;
              }
              return secondFetchCompleter.future;
            },
          );
      final OfflineFirstIotDemoRepository repo = OfflineFirstIotDemoRepository(
        getCurrentSupabaseUserId: () => currentUserId,
        getPersistentRepository: (final String id) =>
            PersistentIotDemoRepository(
              hiveService: hiveService,
              supabaseUserId: id,
              timerService: FakeTimerService(),
            ),
        pendingSyncRepository: pendingRepository,
        registry: registry,
        timerService: FakeTimerService(),
        remoteRepository: controllableRemote,
      );

      final Future<void> firstPull = repo.pullRemote();
      currentUserId = 'other-user-id';
      final Future<void> secondPull = repo.pullRemote();

      // Remote fetch start can be delayed by local storage work (e.g. schema ensure).
      for (int i = 0; i < 20 && controllableRemote.fetchCallCount < 2; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(controllableRemote.fetchCallCount, 2);

      firstFetchCompleter.complete(<IotDevice>[
        const IotDevice(
          id: 'user-a-device',
          name: 'User A Device',
          type: IotDeviceType.light,
        ),
      ]);
      secondFetchCompleter.complete(<IotDevice>[
        const IotDevice(
          id: 'user-b-device',
          name: 'User B Device',
          type: IotDeviceType.plug,
        ),
      ]);
      await firstPull;
      await secondPull;

      final List<IotDevice> devices = await repo.watchDevices().first;
      expect(devices, hasLength(1));
      expect(devices.single.id, 'user-b-device');
    });

    test('entityType is iot_demo', () {
      final OfflineFirstIotDemoRepository repo = buildRepository();
      expect(repo.entityType, 'iot_demo');
    });

    test('is registered in registry', () {
      final OfflineFirstIotDemoRepository repo = buildRepository();
      expect(registry.resolve('iot_demo'), isNotNull);
      expect(registry.resolve('iot_demo'), equals(repo));
    });
  });
}

class _FakeSupabaseRemote extends SupabaseIotDemoRepository {
  _FakeSupabaseRemote() : super();

  final List<String> connectCalls = <String>[];
  final List<String> disconnectCalls = <String>[];
  final List<IotDevice> addDeviceCalls = <IotDevice>[];
  int fetchCallCount = 0;
  List<IotDevice> devices = <IotDevice>[
    const IotDevice(
      id: 'light-1',
      name: 'Living Room Light',
      type: IotDeviceType.light,
    ),
  ];

  @override
  Future<List<IotDevice>> fetchDevices([
    final IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]) async {
    fetchCallCount++;
    return List<IotDevice>.unmodifiable(devices);
  }

  @override
  Future<void> connect(final String deviceId) async {
    connectCalls.add(deviceId);
  }

  @override
  Future<void> disconnect(final String deviceId) async {
    disconnectCalls.add(deviceId);
  }

  @override
  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  ) async {}

  @override
  Future<void> addDevice(final IotDevice device) async {
    addDeviceCalls.add(device);
    devices = List<IotDevice>.from(devices)..add(device);
  }
}

class _ControllableSupabaseRemote extends SupabaseIotDemoRepository {
  _ControllableSupabaseRemote({required this.fetchHandler}) : super();

  final Future<List<IotDevice>> Function() fetchHandler;
  int fetchCallCount = 0;

  @override
  Future<List<IotDevice>> fetchDevices([
    final IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]) async {
    fetchCallCount++;
    return fetchHandler();
  }

  @override
  Future<void> connect(final String deviceId) async {}

  @override
  Future<void> disconnect(final String deviceId) async {}

  @override
  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  ) async {}

  @override
  Future<void> addDevice(final IotDevice device) async {}
}
