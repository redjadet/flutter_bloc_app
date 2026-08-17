import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:utilities/utilities.dart';

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
    @Default(FcmDemoStatus.initial) FcmDemoStatus status,
    @Default(FcmPermissionState.notDetermined)
    FcmPermissionState permissionState,
    String? fcmToken,
    String? apnsToken,
    PushMessage? lastMessage,
    String? errorMessage,
  }) = _FcmDemoState;
}
