import 'dart:async';

import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Subscribes to Supabase Realtime postgres_changes for table `iot_devices`.
///
/// When the table changes (INSERT/UPDATE/DELETE), the provided callback is
/// invoked so the app can pull and reflect remote changes (two-way sync).
///
/// Requires the table to be in the `supabase_realtime` publication:
/// `alter publication supabase_realtime add table iot_devices;`
class IotDemoRealtimeSubscription {
  IotDemoRealtimeSubscription();

  RealtimeChannel? _channel;
  void Function()? _onTableChange;

  /// Starts listening to `iot_devices`. The callback is called on any
  /// change. No-op if Supabase is not initialized or already started.
  void start(final void Function() onTableChange) {
    if (!SupabaseBootstrapService.isSupabaseInitialized) {
      return;
    }
    if (_channel != null) {
      return;
    }
    _onTableChange = onTableChange;
    try {
      final RealtimeChannel channel = Supabase.instance.client
          .channel('iot_demo_devices')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'iot_devices',
            callback: _onPayload,
          );
      _channel = channel;
      channel.subscribe();
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'IotDemoRealtimeSubscription.start failed',
        error,
        stackTrace,
      );
      _onTableChange = null;
    }
  }

  void _onPayload(final PostgresChangePayload payload) {
    final void Function()? cb = _onTableChange;
    if (cb != null) {
      try {
        cb();
      } on Object catch (error, stackTrace) {
        AppLogger.error(
          'IotDemoRealtimeSubscription callback failed',
          error,
          stackTrace,
        );
      }
    }
  }

  /// Stops listening. Safe to call when not started.
  Future<void> stop() async {
    final RealtimeChannel? channel = _channel;
    _channel = null;
    _onTableChange = null;
    if (channel != null) {
      try {
        await Supabase.instance.client.removeChannel(channel);
      } on Object catch (error, stackTrace) {
        AppLogger.error(
          'IotDemoRealtimeSubscription.stop removeChannel failed',
          error,
          stackTrace,
        );
      }
    }
  }
}
