abstract interface class StaffDemoFormsRepository {
  Future<void> submitAvailability({
    required String userId,
    required DateTime weekStartUtc,
    required Map<String, bool> availabilityByIsoDate,
  });

  Future<void> submitManagerReport({
    required String userId,
    required String siteId,
    required String notes,
  });
}
