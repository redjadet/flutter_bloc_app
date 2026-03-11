import 'package:flutter_bloc_app/features/iot_demo/data/iot_demo_realtime_subscription.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockRealtimeChannel extends Mock implements RealtimeChannel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      PostgresChangePayload(
        schema: 'public',
        table: 'iot_devices',
        commitTimestamp: DateTime.utc(2025, 3, 11),
        eventType: PostgresChangeEvent.insert,
        newRecord: const <String, dynamic>{},
        oldRecord: const <String, dynamic>{},
        errors: null,
      ),
    );
  });

  group('IotDemoRealtimeSubscription', () {
    test('start is a no-op when Supabase is not configured', () {
      var createChannelCalls = 0;
      final IotDemoRealtimeSubscription subscription =
          IotDemoRealtimeSubscription(
            isConfiguredOverride: () => false,
            createChannel: (final _) {
              createChannelCalls += 1;
              throw StateError('should not create channel');
            },
          );

      subscription.start(() {});

      expect(createChannelCalls, 0);
    });

    test('start subscribes once and ignores repeated calls', () {
      final _MockRealtimeChannel channel = _MockRealtimeChannel();
      when(() => channel.subscribe()).thenReturn(channel);

      late void Function(PostgresChangePayload payload) onPayload;
      var createChannelCalls = 0;
      final IotDemoRealtimeSubscription subscription =
          IotDemoRealtimeSubscription(
            isConfiguredOverride: () => true,
            createChannel: (final callback) {
              createChannelCalls += 1;
              onPayload = callback;
              return channel;
            },
          );

      var callbackCalls = 0;
      subscription.start(() {
        callbackCalls += 1;
      });
      subscription.start(() {
        callbackCalls += 100;
      });

      expect(createChannelCalls, 1);
      verify(() => channel.subscribe()).called(1);

      onPayload(
        PostgresChangePayload(
          schema: 'public',
          table: 'iot_devices',
          commitTimestamp: DateTime.utc(2025, 3, 11),
          eventType: PostgresChangeEvent.update,
          newRecord: const <String, dynamic>{'id': 'device-1'},
          oldRecord: const <String, dynamic>{},
          errors: null,
        ),
      );

      expect(callbackCalls, 1);
    });

    test('payload callback errors are isolated', () {
      final _MockRealtimeChannel channel = _MockRealtimeChannel();
      when(() => channel.subscribe()).thenReturn(channel);

      late void Function(PostgresChangePayload payload) onPayload;
      final IotDemoRealtimeSubscription subscription =
          IotDemoRealtimeSubscription(
            isConfiguredOverride: () => true,
            createChannel: (final callback) {
              onPayload = callback;
              return channel;
            },
          );

      subscription.start(() {
        throw StateError('callback failed');
      });

      expect(
        () => onPayload(
          PostgresChangePayload(
            schema: 'public',
            table: 'iot_devices',
            commitTimestamp: DateTime.utc(2025, 3, 11),
            eventType: PostgresChangeEvent.update,
            newRecord: const <String, dynamic>{},
            oldRecord: const <String, dynamic>{},
            errors: null,
          ),
        ),
        returnsNormally,
      );
    });

    test('stop removes channel once and clears state', () async {
      final _MockRealtimeChannel channel = _MockRealtimeChannel();
      when(() => channel.subscribe()).thenReturn(channel);

      var removeChannelCalls = 0;
      final IotDemoRealtimeSubscription subscription =
          IotDemoRealtimeSubscription(
            isConfiguredOverride: () => true,
            createChannel: (final _) => channel,
            removeChannel: (final removedChannel) async {
              expect(removedChannel, same(channel));
              removeChannelCalls += 1;
            },
          );

      subscription.start(() {});
      await subscription.stop();
      await subscription.stop();

      expect(removeChannelCalls, 1);
    });
  });
}
