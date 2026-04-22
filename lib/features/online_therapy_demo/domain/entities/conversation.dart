class Conversation {
  const Conversation({
    required this.id,
    required this.participantIds,
    required this.lastMessageAt,
    this.appointmentId,
  });

  final String id;
  final String? appointmentId;
  final List<String> participantIds;
  final DateTime lastMessageAt;
}
