import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_result.dart';

abstract interface class StaffDemoPushTokenRepository {
  /// Registers FCM (and optional APNs) tokens for [userId].
  ///
  /// Always returns a typed [StaffDemoPushTokenResult] — never swallows
  /// unexpected failures as a silent `void` success.
  Future<StaffDemoPushTokenResult> registerTokens({required String userId});
}
