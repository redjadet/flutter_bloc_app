enum CallProvider {
  jitsi,
  simulated,
}

enum CallJoinStatus {
  idle,
  preparing,
  connected,
  failed,
}

class const CallSession({
  required final String id,
  required final String appointmentId,
  required final String roomId,
  required final CallProvider provider,
  required final CallJoinStatus joinStatus,
});
