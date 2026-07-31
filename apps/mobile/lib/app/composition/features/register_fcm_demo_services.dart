import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/firebase_messaging_repository.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/simulated_fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_demo_mode.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_simulation_controller.dart';

/// Registers FCM demo services.
/// When Firebase is not initialized (e.g. placeholder config, web), registers
/// [SimulatedFcmMessagingService] so the FCM demo page loads with deterministic
/// payloads instead of a no-op stub.
void registerFcmDemoServices() {
  if (Firebase.apps.isEmpty) {
    registerLazySingletonIfAbsent<SimulatedFcmMessagingService>(
      SimulatedFcmMessagingService.new,
    );
    registerLazySingletonIfAbsent<FcmMessagingService>(
      () => getIt<SimulatedFcmMessagingService>(),
    );
    registerLazySingletonIfAbsent<FcmSimulationController>(
      () => getIt<SimulatedFcmMessagingService>(),
    );
    registerLazySingletonIfAbsent<FcmDemoMode>(() => FcmDemoMode.simulated);
    return;
  }

  registerLazySingletonIfAbsent<FcmMessagingService>(
    FirebaseMessagingRepository.new,
  );
  registerLazySingletonIfAbsent<FcmDemoMode>(() => FcmDemoMode.live);
}
