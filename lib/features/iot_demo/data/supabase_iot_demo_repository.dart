import 'dart:async';

import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [IotDemoRepository].
///
/// Fetches devices from `iot_devices` table and applies connect/disconnect
/// and commands via updates. When Supabase is not configured, throws or
/// returns empty; used by the offline-first repository for pull and sync.
class SupabaseIotDemoRepository implements IotDemoRepository {
  static const String _table = 'iot_devices';

  static const String _selectColumns = 'id,name,type,last_seen,connection_state,toggled_on,value';

  @override
  Stream<List<IotDevice>> watchDevices([
    final IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]) {
    if (!SupabaseBootstrapService.isSupabaseInitialized) {
      return Stream<List<IotDevice>>.value(const <IotDevice>[]);
    }
    return Stream<List<IotDevice>>.fromFuture(fetchDevices(filter));
  }

  /// Fetches devices from Supabase. Used by offline-first pullRemote (filter=all)
  /// and by watchDevices when filter is toggledOnOnly.
  Future<List<IotDevice>> fetchDevices([
    final IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]) async {
    if (!SupabaseBootstrapService.isSupabaseInitialized) {
      return const <IotDevice>[];
    }
    try {
      final dynamic raw;
      if (filter == IotDemoDeviceFilter.toggledOnOnly) {
        raw = await Supabase.instance.client
            .from(_table)
            .select(_selectColumns)
            .eq('toggled_on', true)
            .order('id');
      } else if (filter == IotDemoDeviceFilter.toggledOffOnly) {
        raw = await Supabase.instance.client
            .from(_table)
            .select(_selectColumns)
            .eq('toggled_on', false)
            .order('id');
      } else {
        raw = await Supabase.instance.client.from(_table).select(_selectColumns).order('id');
      }
      final List<dynamic>? list = listFromDynamic(raw);
      final List<IotDevice> result = <IotDevice>[];
      if (list != null) {
        for (final dynamic item in list) {
          final Map<String, dynamic>? row = mapFromDynamic(item);
          if (row != null) {
            final IotDevice? device = _rowToDevice(row);
            if (device != null) {
              result.add(device);
            }
          }
        }
      }
      return List<IotDevice>.unmodifiable(result);
    } on PostgrestException catch (e, s) {
      AppLogger.error(
        'SupabaseIotDemoRepository.fetchDevices',
        e,
        s,
      );
      rethrow;
    } on Object catch (e, s) {
      AppLogger.error(
        'SupabaseIotDemoRepository.fetchDevices',
        e,
        s,
      );
      rethrow;
    }
  }

  @override
  Future<void> connect(final String deviceId) async {
    if (!SupabaseBootstrapService.isSupabaseInitialized) {
      throw StateError(
        'Supabase is not configured (missing URL or anon key).',
      );
    }
    final String now = DateTime.now().toUtc().toIso8601String();
    await Supabase.instance.client
        .from(_table)
        .update(<String, dynamic>{
          'connection_state': 'connected',
          'last_seen': now,
          'updated_at': now,
        })
        .eq('id', deviceId);
  }

  @override
  Future<void> disconnect(final String deviceId) async {
    if (!SupabaseBootstrapService.isSupabaseInitialized) {
      throw StateError(
        'Supabase is not configured (missing URL or anon key).',
      );
    }
    final String now = DateTime.now().toUtc().toIso8601String();
    await Supabase.instance.client
        .from(_table)
        .update(<String, dynamic>{
          'connection_state': 'disconnected',
          'updated_at': now,
        })
        .eq('id', deviceId);
  }

  @override
  Future<void> addDevice(final IotDevice device) async {
    if (device.id.trim().isEmpty || device.name.trim().isEmpty) {
      throw ArgumentError('device id and name must not be empty');
    }
    if (device.name.length > iotDemoDeviceNameMaxLength) {
      throw ArgumentError(
        'device name must not exceed $iotDemoDeviceNameMaxLength characters',
      );
    }
    if (!SupabaseBootstrapService.isSupabaseInitialized) {
      throw StateError(
        'Supabase is not configured (missing URL or anon key).',
      );
    }
    final String? userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('Must be signed in to add a device.');
    }
    final String typeStr = _deviceTypeToDb(device.type);
    final String now = DateTime.now().toUtc().toIso8601String();
    await Supabase.instance.client.from(_table).insert(<String, dynamic>{
      'id': device.id,
      'name': device.name,
      'type': typeStr,
      'user_id': userId,
      'connection_state': 'disconnected',
      'toggled_on': device.toggledOn,
      'value': iotDemoClampAndRound(
        device.value,
        iotDemoValueMin,
        iotDemoValueMax,
      ),
      'updated_at': now,
    });
  }

  static String _deviceTypeToDb(final IotDeviceType type) {
    switch (type) {
      case IotDeviceType.light:
        return 'light';
      case IotDeviceType.thermostat:
        return 'thermostat';
      case IotDeviceType.plug:
        return 'plug';
      case IotDeviceType.sensor:
        return 'sensor';
      case IotDeviceType.switch_:
        return 'switch_';
    }
  }

  @override
  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  ) async {
    if (!SupabaseBootstrapService.isSupabaseInitialized) {
      throw StateError(
        'Supabase is not configured (missing URL or anon key).',
      );
    }
    final String now = DateTime.now().toUtc().toIso8601String();
    final Map<String, dynamic> updates = <String, dynamic>{
      'last_seen': now,
      'updated_at': now,
    };
    if (command is IotDeviceCommandToggle) {
      final dynamic raw = await Supabase.instance.client
          .from(_table)
          .select('toggled_on')
          .eq('id', deviceId);
      final List<dynamic>? list = listFromDynamic(raw);
      final Map<String, dynamic>? firstRow = list != null && list.isNotEmpty
          ? mapFromDynamic(list.first)
          : null;
      final bool current = boolFromDynamic(
        firstRow?['toggled_on'],
        fallback: false,
      );
      updates['toggled_on'] = !current;
    } else if (command is IotDeviceCommandSetValue) {
      final double v = iotDemoClampAndRound(
        command.value.toDouble(),
        iotDemoValueMin,
        iotDemoValueMax,
      );
      updates['value'] = v;
    }
    await Supabase.instance.client
        .from(_table)
        .update(updates)
        .eq('id', deviceId);
  }

  static IotDevice? _rowToDevice(final Map<String, dynamic> row) {
    final String? id = stringFromDynamicTrimmed(row['id']);
    final String? name = stringFromDynamicTrimmed(row['name']);
    final String? typeStr = stringFromDynamicTrimmed(row['type']);
    if (id == null || id.isEmpty || name == null || typeStr == null) {
      return null;
    }
    final IotDeviceType? type = _parseDeviceType(typeStr);
    if (type == null) return null;
    final DateTime? lastSeen = _parseTimestamp(row['last_seen']);
    final IotConnectionState connectionState = _parseConnectionState(
      row['connection_state'],
    );
    final bool toggledOn = boolFromDynamic(row['toggled_on'], fallback: false);
    final double value = doubleFromDynamic(row['value'], 0);

    return IotDevice(
      id: id,
      name: name,
      type: type,
      lastSeen: lastSeen,
      connectionState: connectionState,
      toggledOn: toggledOn,
      value: value,
    );
  }

  static IotDeviceType? _parseDeviceType(final String value) {
    switch (value) {
      case 'light':
        return IotDeviceType.light;
      case 'thermostat':
        return IotDeviceType.thermostat;
      case 'plug':
        return IotDeviceType.plug;
      case 'sensor':
        return IotDeviceType.sensor;
      case 'switch_':
        return IotDeviceType.switch_;
      default:
        return null;
    }
  }

  /// Parses DB column: enum/string 'disconnected' | 'connecting' | 'connected'.
  static IotConnectionState _parseConnectionState(final dynamic value) {
    final String? s = stringFromDynamic(value)?.trim();
    switch (s) {
      case 'connecting':
        return IotConnectionState.connecting;
      case 'connected':
        return IotConnectionState.connected;
      default:
        return IotConnectionState.disconnected;
    }
  }

  static DateTime? _parseTimestamp(final dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
