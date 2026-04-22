enum AvailabilitySlotStatus {
  available,
  booked,
}

class AvailabilitySlot {
  const AvailabilitySlot({
    required this.id,
    required this.therapistId,
    required this.startAt,
    required this.endAt,
    required this.status,
  });

  final String id;
  final String therapistId;
  final DateTime startAt;
  final DateTime endAt;
  final AvailabilitySlotStatus status;
}
