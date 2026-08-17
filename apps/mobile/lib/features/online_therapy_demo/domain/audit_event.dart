class const AuditEvent({
  required final String id,
  required final String actorId,
  required final String action,
  required final String targetId,
  required final DateTime createdAt,
});
