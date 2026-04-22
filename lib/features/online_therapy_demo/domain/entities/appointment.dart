enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
}

class Appointment {
  const Appointment({
    required this.id,
    required this.therapistId,
    required this.clientId,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.createdAt,
    this.cancelReason,
  });

  final String id;
  final String therapistId;
  final String clientId;
  final DateTime startAt;
  final DateTime endAt;
  final AppointmentStatus status;
  final DateTime createdAt;
  final String? cancelReason;
}
