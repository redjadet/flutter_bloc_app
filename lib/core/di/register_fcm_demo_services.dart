import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/firebase_messaging_repository.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_messaging_service.dart';

/// Registers FCM demo services.
void registerFcmDemoServices() {
  registerLazySingletonIfAbsent<FcmMessagingService>(
    FirebaseMessagingRepository.new,
  );
}
