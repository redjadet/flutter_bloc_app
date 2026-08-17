enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
}

class const Appointment({
  required final String id,
  required final String therapistId,
  required final String clientId,
  required final DateTime startAt,
  required final DateTime endAt,
  required final AppointmentStatus status,
  required final DateTime createdAt,
  final String? cancelReason,
});
