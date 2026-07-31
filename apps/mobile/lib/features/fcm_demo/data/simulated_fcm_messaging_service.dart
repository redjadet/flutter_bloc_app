import 'dart:async';

import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_permission_state.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_simulation_controller.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';

/// Deterministic FCM stand-in when Firebase is not initialized.
class SimulatedFcmMessagingService
    implements FcmMessagingService, FcmSimulationController {
  SimulatedFcmMessagingService();

  static const String simulatedToken = 'sim-fcm-token';

  final StreamController<PushMessage> _foregroundController =
      StreamController<PushMessage>.broadcast();
  final StreamController<PushMessage> _openedController =
      StreamController<PushMessage>.broadcast();
  final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();

  int _simulatedMessageCounter = 0;

  @override
  Future<FcmPermissionState> requestPermission() async =>
      FcmPermissionState.authorized;

  @override
  Future<String?> getToken() async => simulatedToken;

  @override
  Future<String?> getApnsToken() async => null;

  @override
  Future<PushMessage?> getInitialMessage() async => null;

  @override
  Stream<PushMessage> get foregroundMessages => _foregroundController.stream;

  @override
  Stream<PushMessage> get openedMessages => _openedController.stream;

  @override
  Stream<String> get tokenRefreshes => _tokenRefreshController.stream;

  @override
  void emitSimulatedNotification() {
    _simulatedMessageCounter++;
    final PushMessage message = PushMessage(
      messageId: 'sim-msg-$_simulatedMessageCounter',
      title: 'Simulated title $_simulatedMessageCounter',
      body: 'Simulated body $_simulatedMessageCounter',
      sentTime: DateTime.now().toUtc(),
      data: <String, String>{
        'source': 'simulated',
        'index': '$_simulatedMessageCounter',
      },
    );
    _foregroundController.add(message);
  }

  /// Test-only cleanup for stream controllers.
  Future<void> dispose() async {
    await _foregroundController.close();
    await _openedController.close();
    await _tokenRefreshController.close();
  }
}
