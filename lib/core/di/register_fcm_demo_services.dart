import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/firebase_messaging_repository.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/no_op_fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_messaging_service.dart';

/// Registers FCM demo services.
/// When Firebase is not initialized (e.g. placeholder config, web), registers
/// [NoOpFcmMessagingService] so the FCM demo page loads without crashing.
void registerFcmDemoServices() {
  registerLazySingletonIfAbsent<FcmMessagingService>(
    () => Firebase.apps.isEmpty
        ? NoOpFcmMessagingService()
        : FirebaseMessagingRepository(),
  );
}
