enum AvailabilitySlotStatus {
  available,
  booked,
}

class const AvailabilitySlot({
  required final String id,
  required final String therapistId,
  required final DateTime startAt,
  required final DateTime endAt,
  required final AvailabilitySlotStatus status,
});
