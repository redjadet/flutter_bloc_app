/// Outcome of registering FCM/APNs tokens for the staff demo profile.
sealed class StaffDemoPushTokenResult {
  const new();
}

/// Tokens were written to Firestore.
final class StaffDemoPushTokenRegistered extends StaffDemoPushTokenResult {
  const new({required this.hasApnsToken});

  final bool hasApnsToken;
}

/// Registration was skipped for an expected, non-fatal reason.
final class StaffDemoPushTokenSkipped extends StaffDemoPushTokenResult {
  const new(this.reason);

  final StaffDemoPushTokenSkipReason reason;
}

enum StaffDemoPushTokenSkipReason {
  /// Notification permission denied or permanently denied.
  permissionDenied,

  /// iOS simulator / APNs not ready yet (`apns-token-not-set`).
  apnsTokenNotSet,

  /// Messaging returned a null/empty FCM token.
  emptyFcmToken,

  /// Offline / NoOp repository when Firestore (or messaging) is unavailable.
  repositoryUnavailable,
}

/// Unexpected failure while registering tokens.
final class StaffDemoPushTokenFailed extends StaffDemoPushTokenResult {
  const new({required this.cause, this.stackTrace});

  final Object cause;
  final StackTrace? stackTrace;
}
