import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_permission_state.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fcm_demo_state.freezed.dart';

/// Status of the FCM demo screen.
enum FcmDemoStatus {
  initial,
  loading,
  ready,
  error,
}

/// State for the FCM demo page.
@freezed
abstract class FcmDemoState with _$FcmDemoState {
  const factory FcmDemoState({
    @Default(FcmDemoStatus.initial) final FcmDemoStatus status,
    @Default(FcmPermissionState.notDetermined)
    final FcmPermissionState permissionState,
    final String? fcmToken,
    final String? apnsToken,
    final PushMessage? lastMessage,
    final String? errorMessage,
  }) = _FcmDemoState;
}
