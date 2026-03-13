import 'package:flutter_bloc_app/features/iot_demo/data/supabase_iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helpers/supabase_test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await initializeSupabaseForTest();
  });

  tearDown(resetSupabaseTestState);

  group('SupabaseIotDemoRepository', () {
    test(
      'fetchDevices returns parsed devices and skips invalid rows',
      () async {
        late IotDemoDeviceFilter requestedFilter;
        final SupabaseIotDemoRepository repository = SupabaseIotDemoRepository(
          fetchRows: (final filter) async {
            requestedFilter = filter;
            return <Map<String, Object?>>[
              <String, Object?>{
                'id': 'light-1',
                'name': 'Living Room Light',
                'type': 'light',
                'last_seen': '2025-03-11T10:00:00Z',
                'connection_state': 'connected',
                'toggled_on': true,
                'value': 21.5,
              },
              <String, Object?>{
                'id': 'broken',
                'name': 'Broken',
                'type': 'unknown',
              },
            ];
          },
        );

        final List<IotDevice> devices = await repository.fetchDevices(
          IotDemoDeviceFilter.toggledOnOnly,
        );

        expect(requestedFilter, IotDemoDeviceFilter.toggledOnOnly);
        expect(devices, <IotDevice>[
          IotDevice(
            id: 'light-1',
            name: 'Living Room Light',
            type: IotDeviceType.light,
            lastSeen: DateTime.parse('2025-03-11T10:00:00Z'),
            connectionState: IotConnectionState.connected,
            toggledOn: true,
            value: 21.5,
          ),
        ]);
      },
    );

    test(
      'watchDevices returns empty list stream when Supabase is not configured',
      () async {
        resetSupabaseTestState();
        final SupabaseIotDemoRepository repository = SupabaseIotDemoRepository(
          fetchRows: (final _) async =>
              throw StateError('fetchRows should not be called'),
        );

        final List<IotDevice> emitted = await repository
            .watchDevices(IotDemoDeviceFilter.all)
            .first;

        expect(emitted, isEmpty);
      },
    );

    test('fetchDevices rethrows PostgrestException', () async {
      const PostgrestException failure = PostgrestException(
        message: 'table failed',
        code: '500',
      );
      final SupabaseIotDemoRepository repository = SupabaseIotDemoRepository(
        fetchRows: (final _) async => throw failure,
      );

      await expectLater(repository.fetchDevices(), throwsA(same(failure)));
    });

    test('addDevice validates input and requires current user', () async {
      final SupabaseIotDemoRepository repository = SupabaseIotDemoRepository(
        readCurrentUserId: () => null,
      );

      expect(
        () => repository.addDevice(
          const IotDevice(id: '', name: 'Light', type: IotDeviceType.light),
        ),
        throwsArgumentError,
      );
      expect(
        () => repository.addDevice(
          IotDevice(
            id: 'light-1',
            name: 'x' * (iotDemoDeviceNameMaxLength + 1),
            type: IotDeviceType.light,
          ),
        ),
        throwsArgumentError,
      );
      await expectLater(
        repository.addDevice(
          const IotDevice(
            id: 'light-1',
            name: 'Light',
            type: IotDeviceType.light,
          ),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('addDevice inserts normalized payload', () async {
      Map<String, dynamic>? capturedPayload;
      final SupabaseIotDemoRepository repository = SupabaseIotDemoRepository(
        readCurrentUserId: () => 'user-1',
        insertDevice: (final payload) async {
          capturedPayload = payload;
        },
      );

      await repository.addDevice(
        const IotDevice(
          id: 'thermostat-1',
          name: 'Thermostat',
          type: IotDeviceType.thermostat,
          toggledOn: true,
          value: 99.999,
        ),
      );

      expect(capturedPayload, isNotNull);
      expect(capturedPayload!['id'], 'thermostat-1');
      expect(capturedPayload!['user_id'], 'user-1');
      expect(capturedPayload!['type'], 'thermostat');
      expect(capturedPayload!['toggled_on'], isTrue);
      expect(capturedPayload!['value'], iotDemoValueMax);
    });

    test('sendCommand toggle reads current state and flips it', () async {
      String? updatedId;
      Map<String, dynamic>? updatedPayload;
      final SupabaseIotDemoRepository repository = SupabaseIotDemoRepository(
        fetchToggleState: (final deviceId) async => <Map<String, Object?>>[
          <String, Object?>{'toggled_on': false},
        ],
        updateDevice: (final deviceId, final updates) async {
          updatedId = deviceId;
          updatedPayload = updates;
        },
      );

      await repository.sendCommand('light-1', const IotDeviceCommand.toggle());

      expect(updatedId, 'light-1');
      expect(updatedPayload?['toggled_on'], isTrue);
      expect(updatedPayload?['last_seen'], isA<String>());
      expect(updatedPayload?['updated_at'], isA<String>());
    });

    test('sendCommand setValue clamps and rounds numeric values', () async {
      Map<String, dynamic>? updatedPayload;
      final SupabaseIotDemoRepository repository = SupabaseIotDemoRepository(
        updateDevice: (final _, final updates) async {
          updatedPayload = updates;
        },
      );

      await repository.sendCommand(
        'sensor-1',
        const IotDeviceCommand.setValue(12.345),
      );

      expect(updatedPayload?['value'], 12.35);
    });

    test('watchDevices emits devices when Supabase is configured', () async {
      late IotDemoDeviceFilter requestedFilter;
      final SupabaseIotDemoRepository repository = SupabaseIotDemoRepository(
        fetchRows: (final filter) async {
          requestedFilter = filter;
          return <Map<String, Object?>>[
            <String, Object?>{
              'id': 'plug-1',
              'name': 'Desk Plug',
              'type': 'plug',
              'last_seen': '2025-03-12T09:30:00Z',
              'connection_state': 'disconnected',
              'toggled_on': false,
              'value': 0,
            },
          ];
        },
      );

      final List<IotDevice> devices = await repository
          .watchDevices(IotDemoDeviceFilter.all)
          .first;

      expect(requestedFilter, IotDemoDeviceFilter.all);
      expect(devices, <IotDevice>[
        IotDevice(
          id: 'plug-1',
          name: 'Desk Plug',
          type: IotDeviceType.plug,
          lastSeen: DateTime.parse('2025-03-12T09:30:00Z'),
          connectionState: IotConnectionState.disconnected,
          toggledOn: false,
          value: 0,
        ),
      ]);
    });
  });
}
