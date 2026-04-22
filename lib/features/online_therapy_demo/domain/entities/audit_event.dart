class AuditEvent {
  const AuditEvent({
    required this.id,
    required this.actorId,
    required this.action,
    required this.targetId,
    required this.createdAt,
  });

  final String id;
  final String actorId;
  final String action;
  final String targetId;
  final DateTime createdAt;
}
