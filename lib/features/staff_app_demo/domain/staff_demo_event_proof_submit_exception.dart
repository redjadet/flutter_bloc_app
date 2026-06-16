class StaffDemoEventProofOfflineEnqueuedException implements Exception {
  const StaffDemoEventProofOfflineEnqueuedException();
}

/// Local proof asset missing at submit time (photo or signature).
class StaffDemoProofFileMissingException implements Exception {
  StaffDemoProofFileMissingException(this.message);

  final String message;

  @override
  String toString() => message;
}
