import 'package:flutter_bloc_app/features/fcm_demo/data/simulated_fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_permission_state.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimulatedFcmMessagingService', () {
    late SimulatedFcmMessagingService service;

    setUp(() {
      service = SimulatedFcmMessagingService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('requestPermission returns authorized', () async {
      expect(await service.requestPermission(), FcmPermissionState.authorized);
    });

    test('getToken returns deterministic simulated token', () async {
      expect(
        await service.getToken(),
        SimulatedFcmMessagingService.simulatedToken,
      );
    });

    test('emitSimulatedNotification pushes foreground message', () async {
      final Future<PushMessage> next = service.foregroundMessages.first;

      service.emitSimulatedNotification();

      final PushMessage message = await next;
      expect(message.source, PushMessageSource.foreground);
      expect(message.title, isNotEmpty);
      expect(message.body, isNotEmpty);
      expect(message.data, isNotEmpty);
    });
  });
}
