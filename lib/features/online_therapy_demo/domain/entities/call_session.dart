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

class CallSession {
  const CallSession({
    required this.id,
    required this.appointmentId,
    required this.roomId,
    required this.provider,
    required this.joinStatus,
  });

  final String id;
  final String appointmentId;
  final String roomId;
  final CallProvider provider;
  final CallJoinStatus joinStatus;
}
